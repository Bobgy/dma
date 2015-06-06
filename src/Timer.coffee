class Ticker
  # @param id {string}
  # @param tick {int}
  constructor: (@id, @tick) ->
    @valid = true
  update: -> @tick++
  clone: ->
    ticker = new Ticker(@id, @tick)
    ticker.valid = @valid
    return this
  copy: (rhs) ->
    @id = rhs.id
    @tick = rhs.tick
    @valid = rhs.valid
    return this

class Timer extends Ticker
  # @param id {string}
  # @param interval {int}
  # @param callback {function(world, parent)}
  # @param periodic {boolean}
  # @param currentTick {int}
  constructor: (@id='', @interval=0, @callback,
                @periodic=true, currentTick=0) ->
    super(@id, currentTick)
    @copyable = true
  update: (world, otherWorld, parent) ->
    return this unless @valid
    super()
    if @tick == @interval
      if @periodic
        @tick = 0
      else
        @valid = false
        delete parent.components[@id]
      @callback(world, parent)
    return this
  copy: (rhs) ->
    super(rhs)
    @interval = rhs.interval
    @currentTick = rhs.currentTick
    @callback = rhs.callback unless @callback?
    return this
  clone: -> new Timer(@id, @interval, @callback, @periodic, currentTick)

module.exports = Timer
