Core = require('./lib')
util = Core.util
Container = Core.Container
World = Core.World

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
    @io = null

    # init
    SkillSummonServant.init(@worlds[i]) for i in [0..1]

  preset: ->
    super()
    args =
      w: 640
      h: 640
    util.setArgs(@args, args)
    return

  update: =>
    @worlds[i].earlyUpdate(@worlds[i], @worlds[i^1]) for i in [0..1]
    @worlds[i].update(@worlds[i^1]) for i in [0..1]
    if @PIXI?
      @get('ScoreBoard').update(this, this)
      requestAnimationFrame(@animate)
    return

  animate: =>
    @stage.removeChildren()
    @stage.addChild(@worlds[i].stage) for i in [0..1]
    for i in [0..1]
      for player in @worlds[i].players
        @stage.addChild(player.components.sprite) if player.components.sprite?
    @stage.addChild(@get('ScoreBoard').stage)
    @renderer.render(@stage)
    return

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
    @process = new util.AccurateInterval(@update, interval)
    return

module.exports = Game
