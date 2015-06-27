# for FPS analysis
class FPSLogger
  # @param verbose {boolean}: whether log will be displayed
  # @param id {string}
  # @param logInterval {number}: the interval of logging measured in ms
  constructor: (@verbose=false, @id='FPSLogger', @logInterval=10000) ->
    @lastTime = 0
    @lastTick = 0
    @lastLog = 0
    @FPS = 0

  update: (world) ->
    if world.tick - @lastTick > 10
      if @lastTime
        @FPS = (world.tick - @lastTick) / (Date.now() - @lastTime) * 1000
      @lastTime = Date.now()
      @lastTick = world.tick
    if Date.now() - @lastLog > @logInterval and @FPS
      console.log(@id, 'FPS:', @FPS)
      @lastLog = Date.now()

# a helper function to destroy PIXI's displayObjects
# @param obj {PIXI.DisplayObject}
destroyDisplayObject = (obj) ->
  if obj.parent?
    obj.parent.removeChild(obj)
  obj.destroy()

# for packaging (key, value) pairs of arguments
# @param args {Object}
# @param obj {Object}
setArgs = (args, obj) ->
  for key, value of obj
    args[key] = value
  return args

# a helper class to let you use setInterval with auto fixing interval
class AccurateInterval
  constructor: (@fn, @interval) ->
    @valid = true
    @next = Date.now() + @interval
    setTimeout(@gao, @interval)

  gao: =>
    if @valid
      @next += @interval
      if @next - Date.now() < -60
        console.warn('Warning: Framerate is too low, reset!')
        @reset()
      setTimeout(@gao, @next - Date.now())
      @fn()

  reset: -> @next = Date.now() + @interval

  off: -> @valid = false

# a two-dimentional vector class
class Vec2
  constructor: (@x = 0, @y = 0) ->
  add: (rhs) -> new Vec2(@x + rhs.x, @y + rhs.y)
  sub: (rhs) -> new Vec2(@x - rhs.x, @y - rhs.y)
  mul: (rhs) -> new Vec2(@x * rhs.x, @y * rhs.y)
  scale: (k) -> new Vec2(@x * k, @y * k)
  dotMul: (rhs) -> @x * rhs.x + @y * rhs.y
  crossMul: (rhs) -> @x * rhs.y - @y * rhs.x
  length: -> Math.sqrt(@x * @x + @y * @y)
  normalize: (len=1) -> @scale(len/@length())
  rotate: (rad) -> # counter clockwise rotation
    c = Math.cos(rad)
    s = Math.sin(rad)
    new Vec2(@x*c-@y*s, @x*s+@y*c)
  sync: (rhs) ->
    @x = rhs.x
    @y = rhs.y
    this
  clone: -> new Vec2(@x, @y)
  set: (x, y) ->
    @x = x ? 0
    @y = y ? @x
  equals: (rhs) ->
    rhs.x == @x and rhs.y == @y
  copy: (rhs) -> @set(rhs.x, rhs.y)
Vec2.degToRad = Math.PI/180

# for terminating the game
class GameTimer
  # @param id {string}
  # @param gameLength {number}: the length of the game in miliseconds
  constructor: (@id='gameTimer', @gameLength=120000) ->
    @startTime = null
    @cnt = 0

  start: ->
    @startTime = Date.now()

  update: (server) ->
    timeElapsed = Date.now() - @startTime
    console.log("#{timeElapsed/1000} seconds elapsed") if (@cnt++ & 0xff) == 0
    if Date.now() - @startTime > @gameLength
      console.log('Time up')
      server.callOnEnd()
    return

module.exports = {
  FPSLogger
  destroyDisplayObject
  setArgs
  AccurateInterval
  Vec2
  GameTimer
}
