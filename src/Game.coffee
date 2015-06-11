Container = require('./lib/Container')
World = require('./lib/World')
Core = require('./lib')
util = Core.util

SkillSummonServant = require('./scripts/skills/SummonServant.coffee')
class Game extends Container
  # @param id {string/integer}
  # @param PIXI {module}
  constructor: (args, id='game', @PIXI) ->
    super(args, id)
    @worlds = [new World(@args, 0, @PIXI),
              new World(@args, 1, @PIXI)]
    for world in @worlds
      world.game = this
    if @PIXI?
      @renderer = @PIXI.autoDetectRenderer(@args.w, @args.h,
                                           {backgroundColor : 0x66ccff})
      @stage = new @PIXI.Container()

    # stores socket.io handle, should be added later
    @io = null

    # init
    SkillSummonServant.init(@worlds[i]) for i in [0..1]

  preset: ->
    super()
    args =
      w: 1024
      h: 640
    util.setArgs(@args, args)

  update: =>
    @worlds[i].earlyUpdate(@worlds[i], @worlds[i^1]) for i in [0..1]
    @worlds[i].update(@worlds[i^1]) for i in [0..1]
    requestAnimationFrame(@animate) if @PIXI?

  animate: =>
    @stage.removeChildren()
    @stage.addChild(@worlds[i].stage) for i in [0..1]
    for i in [0..1]
      for player in @worlds[i].players
        @stage.addChild(player.components.sprite) if player.components.sprite?
    @renderer.render(@stage)

  # get a world with its id
  # @param id {integer}
  getWorld: (id) ->
    if id in [0, 1]
      return @worlds[id]
    console.log('Error: get Invalid World with id:', id)
    return null

  # @param interval {float}: the frame interval you intend the game to run with
  # @param isFPSon {boolean}: whether logging current FPS in game
  start: (interval=15) ->
    @process = new util.AccurateInterval(@update, interval)

module.exports = Game
