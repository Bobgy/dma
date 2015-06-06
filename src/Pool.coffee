# A fixed pool containing Entities of the same type
# TODO: use a queue to store the empty slots

Entity = require('./Entity.coffee')
Container = require('./Container.coffee')

class Pool extends Container
  # @param size {int}: the pool size
  # @param entity {Entity*}: the template for entities
  constructor: (id, size, entity) ->
    super(id)
    @pool = new Array(size)
    for i in [0..size-1]
      @pool[i] = entity.clone()
      @pool[i].id = i
      @pool[i].valid = false
    @type = 'Pool'

  # This is used when sprites in the pool are the same
  # @param texture {PIXI.Texture}: the texture used to create sprites
  # @param PIXI {optional}: the PIXI module
  # @return {PIXI.Container}: the sprite pool
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
  # @return this
  update: (world, otherWorld, parent) ->
    for entity in @pool
      if entity.valid
        entity.update(world, otherWorld, this)
    super(world, otherWorld, parent)
    return this

  # Find the first empty slot (with an invalid entity) in the pool
  # @return entity {Entity}, if entity.valid then no empty slot is found.
  findFirstEmptySlot: ->
    for entity in @pool
      return entity unless entity.valid
    return @pool[0]

  # @return this
  destroy: (world) ->
    @pool = null
    if @components.spritePool?
      world.stage.removeChild(@components.spritePool)
      @components.spritePool.destroy(true)
      delete @components.spritePool
    return super()

  # @param rhs {Pool*}
  # @return this
  copy: (rhs) ->
    super(rhs)
    for entity in @pool
      entity.copy(rhs.pool[entity.id])
    return this

Pool.create = (rhs, Type) ->
  entity = if Type? then new Type() else new Entity()
  entity.copy(rhs.pool[0])
  pool = new Pool(null, rhs.pool.length, entity)
  return pool.copy(rhs)

module.exports = Pool
