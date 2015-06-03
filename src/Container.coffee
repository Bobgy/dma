# A base class that adds methods related to components
class Container
  # @param id {string}
  constructor: (@id) ->
    @components = new Object()
    # Object.create(null) will make socket.io unable to send this object
    @type = 'Container'

  # update will be called recursively over all components
  # @param world {Container*}: the root container
  # @param parent {Container*}: the parent container
  # @return this
  update: (world, parent) ->
    for id, component of @components
      component.update?(world, this)
    return this

  # copy from rhs
  # @param rhs {Container*}
  # @return this
  copy: (rhs) ->
    if not rhs?
      console.log('Error: copying from rhs which is null or undefined')
      console.log(this)
    @id = rhs.id
    return @copyComponents(rhs)

  # deep copy this
  # @return {Container}: the cloned container
  clone: ->
    container = new Container(@id)
    return container.copyComponents(this)

  # copy components from rhs
  # components with property copyable will be copied
  # existing component will be copied by the copy(rhs) function
  # nonexisting component will be cloned
  # @param rhs {Container*}
  # @return this
  copyComponents: (rhs) ->
    for id, component of rhs.components
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

module.exports = Container
