Vec2 = require('./Vec2.coffee')
Entity = require('./Entity.coffee')
Bullet = require('./Bullet.coffee')
Pool = require('./Pool.coffee')
Servant = require('./Servant.coffee')
Player = require('./Player.coffee')
Container = require('./Container.coffee')

EntityFactory = (type, entity) -> type.create(entity)

class World extends Container
  w: 1024
  h: 720
  constructor: (@PIXI, id='world') ->
    super(id)
    @tick = 0
    @players = []
    @factions = [new Container(0), new Container(1)]
    @user_count = 0
    if @PIXI?
      @renderer = @PIXI.autoDetectRenderer(@w, @h,
              {backgroundColor : 0x66ccff})
      # create the root of the scene graph
      @stage = new @PIXI.Container()
      @animate = => @renderer.render(@stage)

  addPlayer: (player) ->
    len = @players.push(player)
    player.id = player.faction = len - 1
    return this

  addEntity: (faction, entity) ->
    @factions[faction].insert(entity)
    entity.faction = faction
    return this

  update: () =>
    for player in @players
      player.update(this)
    for entities in @factions
      entities.update(this)
    super(this)
    @tick++
    if @PIXI? then requestAnimationFrame(@animate)
    return this

  importEntity: (container, entity) ->
    newEntity = EntityFactory(eval(entity.type), entity)
    if container.type?
      container.insert(newEntity)
    else
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
    @factions = [new Container(0), new Container(1)]
    i = 0
    for faction in factions
      for id, entity of faction.components
        @importEntity(@factions[i], entity)
      i++
    for player in players
      @importEntity(@players, player)
    return this

  keyAction: (user_id, isDown, keyCode) ->
    @players[user_id].keyState[keyCode] = isDown

  run: (interval) ->
    setInterval(@update, interval)

module.exports = World
