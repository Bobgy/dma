Vec2 = require('./Vec2.coffee')
Entity = require('./Entity.coffee')
Bullet = require('./Bullet.coffee')
BulletPool = require('./BulletPool.coffee')
Servant = require('./Servant.coffee')
Player = require('./Player.coffee')

EntityFactory = (type, entity) -> type.create(entity)

class World
  w: 1024
  h: 720
  constructor: (@PIXI) ->
    if @PIXI?
      @renderer = @PIXI.autoDetectRenderer(@w, @h,
              {backgroundColor : 0x66ccff})
      # create the root of the scene graph
      @stage = new @PIXI.Container()
      @animate = => @renderer.render(@stage)
    @tick = 0
    @updating = false
    @players = []
    @factions = []
    @user_count = 0

  addPlayer: (player) ->
    @players.push(player)
    @factions.push([])
    return this
  addEntity: (faction, entity) ->
    entity.id = @factions[faction].push(entity) - 1
    return this
  update: () =>
    @updating = true
    for entities in @factions
      for entity in entities
        entity.update(this)
    for player in @players
      player.update(this)
      if player.valid
        for id in [0..@factions.length-1]
          entities = @factions[id]
          if player.playerID isnt id
            for servant in entities
              for bullet in servant.pool.pool
                if player.testCollision(bullet)
                  player.die()
                  bullet.die()
    @tick++
    if @PIXI? then requestAnimationFrame(@animate)
    @updating = false
    return this

  importEntity: (container, entity) ->
    newEntity = EntityFactory(eval(entity.type), entity)
    container.push(newEntity)
    if PIXI?
      if entity.type is 'Servant'
        spritePool = newEntity.pool.initSprite(@assets['Bullet'].texture, PIXI)
        @stage.addChild(spritePool)
      texture = @assets[entity.type].texture
      newEntity.initSprite(texture, PIXI)
      @stage.addChild(newEntity.components.sprite)
    return this

  sync: (players, factions) ->
    @players = []
    for sprite in @stage?.removeChildren()
      sprite.destroy()
    @factions = []
    for entities in factions
      id = @factions.push([])
      for entity in entities
        @importEntity(@factions[id-1], entity)
    for player in players
      @importEntity(@players, player)
    return this

  keyAction: (user_id, isDown, keyCode) ->
    @players[user_id].keyState[keyCode] = isDown

  run: (interval) ->
    setInterval(@update, interval)

module.exports = World
