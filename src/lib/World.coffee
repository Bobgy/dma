"use strict"

Entity = require('./Entity')
Bullet = require('./Bullet')
Pool = require('./Pool')
Servant = require('./Servant')
Player = require('./Player')
Container = require('./Container')
util = require('./util')
Vec2 = util.Vec2

EventEmitter = require('./EventEmitter')

EntityFactory = (type, entity) -> type.create(entity)

class World extends Container
  # @param id {string*}
  # @param w, h {integer}: width and height of the stage
  # @param PIXI {module, optional}: passed to init graphics
  verbose: false
  constructor: (args, id='world', @PIXI) ->
    super(args, id)

    @stage = new @PIXI.Container() if @PIXI?

    @players = []
    @insert(new Container(null, 'pools'), this)
    @insert(new Container(null, 'enemies'), this)
    @insert(new util.FPSLogger(@verbose, 'Logger_' + id), this) if @verbose
    @insert(new EventEmitter('eventEmitter'), this)
    @components.eventEmitter
      .on('key', @keyAction)
      .on('sync', @sync)
      .on('syncPlayer', @syncPlayer)

    @tick = 0

    @game = null
    @process = null

  # @param player {Player}
  addPlayer: (player) ->
    player.id = @players.push(player) - 1
    return this

  # @param entity {Entity*}
  addEntity: (entity) ->
    @components.enemies.insert(entity, this)
    return this

  earlyUpdate: ->
    @tick++
    return super(this)

  update: ->
    for player in @players
      player.update(this, this)
    return super(this, this)

  # @param container {Array/Container*}
  # @param entity {Entity*}
  importEntity: (container, entity) ->
    newEntity = EntityFactory(eval(entity.type), entity)
    if container.type?
      container.insert(newEntity, this)
    else
      container.push(newEntity)
      newEntity.init?(this, container)
    return this

  # synchronize the game with given arguments
  # @param tick {integer}
  # @param players {Array of Players}
  # @param enemies {Container*}
  # @param eventEmitter {EventEmitter}
  sync: (tick, players, enemies, eventEmitter, pools) ->
    @tick = tick
    @players = []

    for player in players
      @importEntity(@players, player)

    if pools? or enemies?
      if @stage?
        for sprite in @stage.removeChildren()
          sprite.destroy()

    if pools?
      @components.pools = new Container(null, 'pools')
      for id, pool of pools.components
        newPool = Pool.create(pool, eval(pool.pool[0].type))
        @components.pools.insert(newPool, this)
      @components.pools.cnt = pools.cnt

    if enemies?
      @components.enemies = new Container(null, 'enemies')
      @components.enemies.cnt = enemies.cnt
      for id, entity of enemies.components
        @importEntity(@components.enemies, entity)

    @components.eventEmitter.clearEvent().copy(eventEmitter) if eventEmitter?
    return this

  syncPlayer: (players) ->
    for player in @players
      player.destroy(this)
    @players = []
    for player in players
      @importEntity(@players, player)

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

  clone: -> (new World(@args)).copy(this)

module.exports = World
