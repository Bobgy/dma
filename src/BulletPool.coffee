Bullet = require('./Bullet.coffee')

# A fixed pool containing bullets of the same type
# int size: the maximum expected number of bullets in the screen
# Bullet bulletPrototype: a prototype used to initialize the pool
# TODO: use a queue to store the empty slots

class BulletPool
  # @param size {int}: the pool size
  # @param bullet {Bullet}: the template for bullets
  constructor: (size, bullet) ->
    @pool = new Array(size)
    for i in [0..size-1]
      @pool[i] = bullet.clone()
      @pool[i].id = i
      @pool[i].valid = false
    @components = Object.create(null)
    @type = 'BulletPool'

  # @param texture {PIXI.Texture}: the texture used to create sprites
  # @param PIXI {optional}: the module, left empty to initialize a bulletPool
  # without graphics
  initSprite: (texture, PIXI) ->
    if @components.spritePool?
      console.log('BulletPool has already been initialized.')
      return null
    spritePool = @components.spritePool = new PIXI.Container()
    for bullet in @pool
      bullet.initSprite(texture, PIXI)
      spritePool.addChild(bullet.components.sprite)
    return spritePool

  # update the bullets when bullet.valid = true
  # @param world {World}: handle to the world
  update: (world) ->
    for bullet in @pool
      if bullet.valid
        bullet.update(world)
    return this

  # find the first empty slot (with an invalid bullet) in the pool
  # @return bullet {Bullet}, bullet.valid means not found
  findFirstEmptySlot: ->
    for bullet in @pool
      if not bullet.valid then return bullet
    return @pool[0]

  destroy: ->
    @pool = null
    @components.spritePool?.destroy(true)
    delete @components.spritePool
    @components = null

  copy: (rhs) ->
    for bullet in @pool
      bullet.copyStatus(rhs.pool[bullet.id])
            .copyComponents(rhs.pool[bullet.id])
    for name, component of rhs.components
      if component.copyable
        @components[name] = component.clone()
    return this

BulletPool.create = (rhs) ->
  bullet = new Bullet()
  bullet.copy(rhs.pool[0])
  bulletPool = new BulletPool(rhs.pool.length, bullet)
  return bulletPool.copy(rhs)

module.exports = BulletPool
