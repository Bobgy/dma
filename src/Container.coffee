# A base class that adds methods related to components
class Container
  # @param id {string}
  constructor: (@id) ->
    @components = new Object()
    # Object.create(null) will make socket.io unable to send this object
    @cnt = 0
    @type = 'Container'

  # init will be called only once when the world initializes
  # @param world {Container*}: the root container
  # @param parent {Container*}: the parent container
  # @return this
  init: (world, otherWorld, parent) ->
    for id, component of @components
      component.init?(world, otherWorld, parent)
    return this

  # earlyUpdate will be called recursively over all components
  # @param world {Container*}: the root container
  # @param parent {Container*}: the parent container
  # @return this
  earlyUpdate: (world, otherWorld, parent) ->
    for id, component of @components
      component.earlyUpdate?(world, otherWorld, this)
    return this

  # update will be called recursively over all components
  # @param world {Container*}: the root container
  # @param parent {Container*}: the parent container
  # @return this
  update: (world, otherWorld, parent) ->
    for id, component of @components
      component.update?(world, otherWorld, this)
    return this

  # copy from obj
  # @param obj {Container*}
  # @return this
  copy: (obj) ->
    if not obj?
      console.log('Error: copying from obj which is null or undefined')
      console.log(this)
    @id = obj.id
    @cnt = obj.cnt
    return @copyComponents(obj)

  # deep copy this
  # @return {Container}: the cloned container
  clone: ->
    container = new Container(@id)
    return container.copyComponents(this)

  # copy components from obj
  # components with property copyable will be copied
  # existing component will be copied by the copy(obj) function
  # nonexisting component will be cloned
  # @param obj {Container*}
  # @return this
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
  # @return this
  destroy: ->
    for id, component of @components
      component.destroy?()
    @components = null
    return this

  # @param obj {Object*}
  # @return this
  insert: (obj) ->
    obj.id = @cnt++ unless obj.id?
    if @components[obj.id]?
      console.log('Error: Replacing existing id!')
      console.log(this)
      console.log(obj)
    @components[obj.id] = obj
    return this

  # @param obj {Object*}
  # @return this
  remove: (obj) ->
    if not @components[obj.id]?
      console.log('Error: Removing nonexistant id!')
      console.log(this)
      console.log(obj)
    delete @components[obj.id]
    return this

module.exports = Container
