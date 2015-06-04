# EventEmitter contains events
# Events should have (name, tick, args...)
class EventEmitter
  copyable: true
  constructor: ->
    @list = []
    @listeners = new Object()

  # @return {int}: the index of pushed event
  pushEvent: (name, tick, args...) ->
    return @list.push(new Event(name, tick, args)) - 1
  on: (name, callback) ->
    @listeners[name] = [] unless @listeners[name]?
    @listeners[name].push(callback)
    return this
  earlyUpdate: (world) ->
    delList = []
    for id, event of @list
      if event.tick <= world.tick
        listeners = @listeners[event.name]
        if listeners?
          for listener in listeners
            listener.apply(world, event.args)
        delList.push(id)
    for id in delList
      @list.splice(delList, 1)
    return this
  clearEvent: ->
    @list = []
    return this
  destroy: ->
    @list = null
    @listeners = null
    return this
  copy: (rhs, tick=-1) ->
    for event in rhs.list
      @list.push(event) if event.tick > tick
    return this

# Immutable
class Event
  constructor: (@name, @tick, @args) ->

class FixedsizeEventEmitter extends EventEmitter
  constructor: (@maxSize) ->
    super()
    @last = -1
  pushEvent: (name, tick, args...) ->
    if @list.length == @maxSize
      @last = if @last + 1 == @maxSize then 0 else @last + 1
      @list[@last] = new Event(name, tick, args)
    else
      @last = super()
    return @last

module.exports = [EventEmitter, FixedsizeEventEmitter]
