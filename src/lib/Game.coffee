Container = require('./Container.coffee')
World = require('./World.coffee')
AccurateInterval = require('./AccurateInterval.coffee')
SkillSummonServant = require('../scripts/skills/SummonServant.coffee')
class Game extends Container
  w: 1024
  h: 720
  # @param id {string/integer}
  # @param PIXI {module}
  constructor: (id='game', @PIXI) ->
    super(id)
    @worlds = [new World(0, @w, @h, @PIXI),
              new World(1, @w, @h, @PIXI)]
    for world in @worlds
      world.game = this
    if @PIXI?
      @renderer = @PIXI.autoDetectRenderer(@w, @h, {backgroundColor : 0x66ccff})
      @stage = new @PIXI.Container()

    # stores socket.io handle, should be added later
    @io = null

    # init
    SkillSummonServant.init(@worlds[i]) for i in [0..1]

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
    @process = new AccurateInterval(@update, interval)

module.exports = Game
