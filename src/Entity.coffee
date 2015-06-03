class Entity
  constructor: (@pos, @v) ->
    @id = -1 #uninitilized value
    @valid = true
    @components = new Object()
    # Object.create(null) will make socket.io unable to send this object
  update: (world) ->
    @pos.copy(@pos.add(@v))
    for name, component of @components
      component.update?(world, this)
    return this
  copy: (rhs) ->
    @pos.copy(rhs.pos)
    @v.copy(rhs.v)
    @id = rhs.id
    @valid = rhs.valid
    return @copyComponents(rhs)
  clone: ->
    entity = new Entity(new Vec2(), new Vec2())
    return entity.copy(this)
  copyComponents: (rhs) ->
    for name, component of rhs.components
      if component.copyable
        if @components[name]?
          @components[name].copy(component)
        else
          @components[name] = component.clone()
    return this
  destroy: ->
    @pos = null
    @v = null
    for name, component of @components
      component.destroy?()
    @components = null
    return this
  initSprite: (texture, PIXI) ->
    if @components.sprite
      console.log('Error: Entity already has a sprite.')
      return this
    sprite = new PIXI.Sprite(texture)
    sprite.anchor.set(0.5, 0.5)
    sprite.position = @pos
    sprite.visible = @valid
    @components.sprite = sprite
    return this

module.exports = Entity
