# A fixed pool containing Entities of the same type
# TODO: use a queue to store the empty slots

Entity = require('./Entity.coffee')


class Pool
  # @param size {int}: the pool size
  # @param entity {Entity*}: the template for entities
  constructor: (size, entity) ->
    @pool = new Array(size)
    for i in [0..size-1]
      @pool[i] = entity.clone()
      @pool[i].id = i
      @pool[i].valid = false
    @components = new Object()
    @type = 'Pool'

  # This is used when sprites in the pool are the same
  # @param texture {PIXI.Texture}: the texture used to create sprites
  # @param PIXI {optional}: the PIXI module
  initSprite: (texture, PIXI) ->
    if @components.spritePool?
      console.log('BulletPool has already been initialized.')
      return this
    spritePool = @components.spritePool = new PIXI.Container()
    for entity in @pool
      entity.initSprite(texture, PIXI)
      spritePool.addChild(entity.components.sprite)
    return spritePool

  # Update the entities when entity.valid = true.
  # They will be called by `update(world, parent)` where parent refers
  # to this pool.
  # @param world {World}: handle to the world
  update: (world) ->
    for entity in @pool
      if entity.valid
        entity.update(world, this)
    for name, component of @components
      component.update?(world, this)
    return this

  # Find the first empty slot (with an invalid entity) in the pool
  # @return entity {Entity}, if entity.valid then no empty slot is found.
  findFirstEmptySlot: ->
    for entity in @pool
      if not entity.valid then return entity
    return @pool[0]

  destroy: ->
    @pool = null
    @components.spritePool?.destroy(true)
    delete @components.spritePool
    for name, component of @components
      component.destroy?()
    @components = null

  copy: (rhs) ->
    for entity in @pool
      entity.copy(rhs.pool[entity.id])
    for name, component of rhs.components
      if component.copyable
        if @component[name]?
          @component[name].copy(component)
        else
          @components[name] = component.clone()
    return this

Pool.create = (rhs, Type) ->
  entity = if Type? then new Type() else new Entity()
  entity.copy(rhs.pool[0])
  pool = new Pool(rhs.pool.length, entity)
  return pool.copy(rhs)

module.exports = Pool
