"use strict"

core = require('./core')
util = core.util
Container = core.Container
World = core.World
Vec2 = util.Vec2

gui = require('./ui/gui')

SkillSummonServant = require('./scripts/skills/SummonServant')

class Game extends Container
  # @param args {Object}
  #   w {integer} width
  #   h {integer} height
  #
  # @param id {string/integer}
  # @param PIXI {module}
  constructor: (args, id='game', @PIXI) ->
    super(args, id)
    @worlds = [new World(@args, 0, @PIXI),
              new World(@args, 1, @PIXI)]
    for world in @worlds
      world.game = this
    @score = [0, 0]
    if @PIXI?
      @renderer = @PIXI.autoDetectRenderer(@args.w, @args.h,
                                           {backgroundColor : 0x66ccff})
      @stage = new @PIXI.Container()
      @insert(new gui.ScoreBoard(null, 'ScoreBoard', @PIXI), this)

    # stores socket.io handle, should be added later
    @server = null
    @sockets = null
    @users = null

    @process = null

    # init
    SkillSummonServant.init(@worlds[i]) for i in [0..1]

  preset: ->
    super()
    args =
      w: 640
      h: 640
    util.setArgs(@args, args)
    return this

  update: =>
    @worlds[i].earlyUpdate(@worlds[i], @worlds[i^1]) for i in [0..1]
    @worlds[i].update(@worlds[i^1]) for i in [0..1]
    @components.gameTimer?.update(@server)
    if @PIXI?
      @get('ScoreBoard').update(this, this)
      requestAnimationFrame(@animate)
    return

  destroy: ->
    @process.off()
    for world in @worlds
      world.destroy()

  animate: =>
    @stage.removeChildren()
    @stage.addChild(@worlds[i].stage) for i in [0..1]
    for i in [0..1]
      for player in @worlds[i].players
        @stage.addChild(player.components.sprite) if player.components.sprite?
    @stage.addChild(@get('ScoreBoard').stage)
    @renderer.render(@stage)
    return

  initPlayers: ->
    for user in [0..1]
      pos = new Vec2(400, if user then 500 else 100)
      face = new Vec2(0, if user then -1 else 1)
      player = new core.Player(null, user, pos, new Vec2(), face)
      player.insert(new SkillSummonServant(null, 'skill'))
      @worlds[user].addPlayer(player)
    return this

  # get a world with its id
  # @param id {integer}
  getWorld: (id) ->
    if id in [0, 1]
      return @worlds[id]
    console.error("Error: getting invalid world with id #{id}")
    return

  # @param interval {float}: the frame interval you intend the game to run with
  # @param isFPSon {boolean}: whether logging current FPS in game
  start: (interval=15) ->
    if @components.gameTimer?
      @components.gameTimer.start()
    @process = new util.AccurateInterval(@update, interval)
    return this

  broadcast: (args...) ->
    if not @sockets? then throw new Error('Sockets is null')
    console.dir(args)
    for user in @users
      socket = @sockets[user]
      socket.emit.apply(socket, args) if socket?
    return this

module.exports = Game
