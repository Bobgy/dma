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
      console.log(@id, 'FPS:', @FPS) if @verbose
      @lastLog = Date.now()

destroyDisplayObject = (obj) ->
  if obj.parent?
    obj.parent.removeChild(obj)
  obj.destroy()

# for packaging (key, value) pairs of arguments
setArgs = (args, obj) ->
  for key, value of obj
    args[key] = value
  return args

module.exports = {FPSLogger, destroyDisplayObject, setArgs}
