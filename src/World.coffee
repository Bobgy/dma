Vec2 = require('./Vec2.coffee')
Entity = require('./Entity.coffee')
Bullet = require('./Bullet.coffee')
Pool = require('./Pool.coffee')
Servant = require('./Servant.coffee')
Player = require('./Player.coffee')
Container = require('./Container.coffee')
[EventEmitter, FixedsizeEventEmitter] = require('./EventEmitter.coffee')

EntityFactory = (type, entity) -> type.create(entity)

class World extends Container
  # @param id {string*}
  # @param w, h {integer}: width and height of the stage
  # @param PIXI {module, optional}: passed to init graphics
  constructor: (id='world', @w=1024, @h=720, @PIXI) ->
    super(id)

    @players = []
    @insert(new Container('enemies'))
    @insert(new EventEmitter('eventEmitter'))
    @components.eventEmitter.on('key', @keyAction)
    @components.eventEmitter.on('sync', @sync)

    @tick = 0

    @stage = new @PIXI.Container() if @PIXI?
    @game = null
    @process = null

  # @param player {Player}
  addPlayer: (player) ->
    player.id = @players.push(player) - 1
    player.faction = 0
    return this

  # @param entity {Entity*}: require entity.faction being valid
  addEntity: (entity) ->
    @components.enemies.insert(entity)
    return this

  earlyUpdate: (otherWorld) ->
    @tick++
    return super(this, otherWorld)

  # @param otherWorld {World}: the opponent's world
  update: (otherWorld) ->
    for player in @players
      player.update(this, otherWorld)
    return super(this, otherWorld)

  # @param container {Array/Container*}
  # @param entity {Entity*}
  importEntity: (container, entity) ->
    newEntity = EntityFactory(eval(entity.type), entity)
    if container.type?
      container.insert(newEntity)
    else
      container.push(newEntity)
    PIXI = @game.PIXI
    if PIXI?
      if entity.type is 'Servant'
        spritePool = newEntity.pool.initSprite(@game.assets['Bullet'].texture, PIXI)
        @stage.addChild(spritePool)
      texture = @game.assets[entity.type].texture
      newEntity.initSprite(texture, PIXI)
      if entity.type isnt 'Player'
        @stage.addChild(newEntity.components.sprite)
    return this

  # synchronize the game with given arguments
  # @param tick {integer}
  # @param players {Array of Players}
  # @param enemies {Container*}
  # @param eventEmitter {EventEmitter}
  sync: (tick, players, enemies, eventEmitter) ->
    @tick = tick
    @players = []
    for player in players
      @importEntity(@players, player)
    if enemies?
      @components.enemies = new Container('enemies')
      if @stage?
        for sprite in @stage.removeChildren()
          sprite.destroy()
      @components.enemies.cnt = enemies.cnt
      for id, entity of enemies.components
        @importEntity(@components.enemies, entity)
    @components.eventEmitter.clearEvent().copy(eventEmitter) if eventEmitter?
    return this

  copy: (obj) ->
    super(obj)
    @sync(obj.tick, obj.players)
    return this

  # @param userID {integer}
  # @param isDown {boolean}
  # @param keyCode {integer}
  # @return {boolean}: whether the keyAction changed keyState
  keyAction: (userID, isDown, keyCode) ->
    keyState = @players[userID].keyState
    oldState = keyState[keyCode]
    return oldState isnt (keyState[keyCode] = isDown)

  clone: -> (new World()).copy(this)

module.exports = World
