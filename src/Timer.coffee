class Ticker
  # @param name {string}
  # @param tick {int}
  constructor: (@name, @tick) ->
    @valid = true
  update: -> @tick++
  clone: ->
    ticker = new Ticker(@name, @tick)
    ticker.valid = @valid
    return this
  copy: (rhs) ->
    @name = rhs.name
    @tick = rhs.tick
    @valid = rhs.valid
    return this


class Timer extends Ticker
  # @param name {string}
  # @param interval {int}
  # @param callback {function(world, parent)}
  # @param periodic {boolean}
  # @param currentTick {int}
  constructor: (@name='', @interval=0, @callback,
                @periodic=true, currentTick=0) ->
    super(@name, currentTick)
    @copyable = true
  update: (world, parent) ->
    return this unless @valid
    super()
    if @tick == @interval
      if @periodic
        @tick = 0
      else
        @valid = false
      @callback(world, parent)
    return this
  copy: (rhs) ->
    super(rhs)
    @interval = rhs.interval
    @currentTick = rhs.currentTick
    @callback = rhs.callback unless @callback?
    return this
  clone: -> new Timer(@name, @interval, @callback, @periodic, currentTick)

module.exports = Timer
