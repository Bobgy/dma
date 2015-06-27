"use strict"

# EventEmitter contains events
# Events should have (name, tick, args...)
class EventEmitter
  constructor: (@id) ->
    @list = []
    @listeners = new Object()
    @copyable = true

  # @param name {string}
  # @param tick {int}: the tick this event happened / will happen
  # @param args {Array}: the other arguments
  pushEvent: (name, tick, args...) ->
    @list.push(new Event(name, tick, args))
    return this

  # @param name {string}
  # @param callback {function}
  on: (name, callback) ->
    @listeners[name] = [] unless @listeners[name]?
    @listeners[name].push(callback)
    return this

  # @param world {World}
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

  # @param tick {int}: only events with tick greater than this will be copied
  copy: (obj, tick=-1) ->
    for event in obj.list
      @list.push(event) if event.tick > tick
    return this

# Immutable
class Event
  constructor: (@name, @tick, @args) ->

# a event emitter with a fixed pool size, new events will replace old ones
class FixedsizeEventEmitter extends EventEmitter
  # @param capacity {int}: the capacity of this event emitter
  constructor: (@capacity) ->
    super()
    @last = -1

  # @param name {string}
  # @param tick {int}
  # @param args {Object}
  pushEvent: (name, tick, args...) ->
    console.assert(@list.length <= @capacity)
    if @list.length == @capacity
      @last = if @last + 1 == @capacity then 0 else @last + 1
      @list[@last] = new Event(name, tick, args)
    else
      super()
      @last = @list.length - 1
    return this

EventEmitter.FixedsizeEventEmitter = FixedsizeEventEmitter;

module.exports = EventEmitter
