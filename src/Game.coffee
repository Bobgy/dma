Container = require('./Container.coffee')
World = require('./World.coffee')
AccurateInterval = require('./AccurateInterval.coffee')
SkillSummonServant = require('./scripts/skills/SummonServant.coffee')
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
    if @PIXI
      @renderer = @PIXI.autoDetectRenderer(@w, @h, {backgroundColor : 0x66ccff})

    @tick = 0
    # for FPS analysis
    @lastTime = Date.now()
    @lastTick = 0

    # stores socket.io handle, should be added later
    @io = null

    # init
    SkillSummonServant.init(@worlds[i]) for i in [0..1]

  update: =>
    @tick++
    @worlds[i].earlyUpdate(@worlds[i], @worlds[i^1]) for i in [0..1]
    for i in [0..1]
      @worlds[i].update(@worlds[i^1])
    requestAnimationFrame(@animate) if @PIXI?

  animate: =>
    stage = new @PIXI.Container()
    stage.addChild(@worlds[i].stage) for i in [0..1]
    for i in [0..1]
      for player in @worlds[i].players
          stage.addChild(player.components.sprite) if player.components.sprite?
    @renderer.render(stage)

  logFPS: =>
    FPS = (@tick - @lastTick)/(Date.now() - @lastTime)*1000
    @lastTick = @tick
    @lastTime = Date.now()
    console.log('FPS:', FPS)

  # @param interval {float}: the frame interval you intend the game to run with
  # @param isFPSon {boolean}: whether logging current FPS in game
  start: (interval=15, isFPSon=false) ->
    @process = new AccurateInterval(@update, interval)
    setInterval(@logFPS, 1000) if isFPSon

module.exports = Game
