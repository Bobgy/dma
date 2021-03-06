Container = require('./Container')
util = require('./util')

class Ticker extends Container
  # @param args:
  #   initTick {int}: the initial tick
  #
  # @param id {string}
  constructor: (args, id, @tick) ->
    super(args, id)
    @valid = true

  update: (world, parent) ->
    super(world, parent)
    @tick++ if @valid

  clone: -> (new Ticker(args)).copy(this)

  copy: (obj) ->
    super(obj)
    @tick = obj.tick
    @valid = obj.valid
    return this

class Timer extends Ticker
  # @param args:
  #   interval {int}
  #   periodic {boolean}
  #
  # @param id {string}
  # @param interval {int}
  # @param callback {function(world, parent)}
  # @param periodic {boolean}
  # @param currentTick {int}
  constructor: (args, id, initTick=0, @callback) ->
    super(args, id, initTick)
    @copyable = true
  preset: ->
    super()
    args =
      interval: 0
      periodic: true
    util.setArgs(@args, args)
  update: (world, parent) ->
    return this unless @valid
    super(world, parent)
    if @tick == @args.interval
      if @args.periodic
        @tick = 0
      else
        @valid = false
        delete parent.components[@id]
      @callback.call(parent, world)
    return this
  copy: (obj) ->
    super(obj)
    @valid = obj.valid
    @callback = rhs.callback unless @callback?
    return this
  clone: -> new Timer(@args, @id, @currentTick, @callback)

module.exports = Timer
