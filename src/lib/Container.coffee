util = require('./util')

# A base class that adds methods related to components
class Container
  # @param id {string}
  constructor: (args, @id) ->
    @preset()
    util.setArgs(@args, args) if args?
    @components = new Object()
    # Object.create(null) will make socket.io unable to send this object
    @cnt = 0
    @type = 'Container'

  # preset your @args
  preset: -> @args = {}

  # init will be called when inserted into a container in a world
  # @param world {Container*}: the root container
  # @param parent {Container*}: the parent container
  init: (world, parent) ->
    for id, component of @components
      component.init?(world, this)
    return this

  # earlyUpdate will be called recursively over all components
  # @param world {Container*}: the root container
  # @param parent {Container*}: the parent container
  earlyUpdate: (world, parent) ->
    for id, component of @components
      component.earlyUpdate?(world, this)
    return this

  # update will be called recursively over all components
  # @param world {Container*}: the root container
  # @param parent {Container*}: the parent container
  update: (world, parent) ->
    for id, component of @components
      component.update?(world, this)
    return this

  # copy from obj
  # @param obj {Container*}
  copy: (obj) ->
    if not obj?
      console.log(this)
      throw new Error("copying from obj which is null or undefined")
    @id = obj.id
    @cnt = obj.cnt
    return @copyComponents(obj)

  # deep copy this
  # @return {Container}: the cloned container
  clone: ->
    container = new Container(null, @id)
    return container.copyComponents(this)

  # copy components from obj
  # components with property copyable will be copied
  # existing component will be copied by the copy(obj) function
  # nonexisting component will be cloned
  # @param obj {Container*}
  copyComponents: (obj) ->
    @cnt = obj.cnt
    for id, component of obj.components
      if component.copyable
        if @components[id]?
          @components[id].copy(component)
        else
          @components[id] = component.clone()
    return this

  # destroys this container and its components
  # only Objects need to be destroyed
  # @param world {World}
  # @param parent {Container*}
  destroy: (world, parent) ->
    for id, component of @components
      component.destroy?(world, this)
    @components = null
    parent.remove(@id) if parent? and parent.remove?
    return this

  get: (id) ->
    if not @components[id]?
      console.log(this)
      throw new Error("Getting nonexistant component #{id}")
    return @components[id]

  # @param obj {Object*}
  # @param world {World, optional}: call init when provided
  insert: (obj, world) ->
    obj.id = @cnt++ unless obj.id?
    if @components[obj.id]?
      console.log(this)
      console.log(obj)
      throw new Error("Replacing existing id: #{obj.id}")
    @components[obj.id] = obj
    obj.init?(world, this) if world?
    return this

  # @param id {string/integer}
  remove: (id) ->
    if not @components[id]?
      console.log(this)
      throw new Error("Removing nonexistant id: #{id}!")
    delete @components[id]
    return this

module.exports = Container
