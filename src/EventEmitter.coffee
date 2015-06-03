# EventEmitter contains events
# Events should have (name, tick, args...)
class EventEmitter
  copyable: true
  constructor: ->
    @list = []
    @listeners = new Object()
  pushEvent: (name, tick, args...) ->
    @list.push(new Event(name, tick, args))
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
  destroy: ->
    @list = null
    @listeners = null
  copy: (rhs) ->
    for event in rhs.list
      @list.push(event)
    @listeners = rhs.listeners

# Immutable
class Event
  constructor: (@name, @tick, @args) ->

module.exports = EventEmitter
