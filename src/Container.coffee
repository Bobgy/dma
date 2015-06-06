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
  init: (world, parent) ->
    for id, component of @components
      component.init?(world, parent)
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
    if parent?
      parent.remove(@id)
    else
      console.log('parent:', parent)
    return this

  # @param obj {Object*}
  insert: (obj) ->
    obj.id = @cnt++ unless obj.id?
    if @components[obj.id]?
      console.log('Error: Replacing existing id!')
      console.log(this)
      console.log(obj)
    @components[obj.id] = obj
    return this

  # @param obj {Object*}
  remove: (id) ->
    if not @components[id]?
      console.log("Error: Removing nonexistant id: #{id}!")
      console.log(this)
    delete @components[id]
    return this

module.exports = Container
