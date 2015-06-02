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
			@pool[i].id = i;
			@pool[i].valid = false
		@type = 'BulletPool'

	# @param texture {PIXI.Texture}: the texture used to create sprites
	# @param PIXI {optional}: the module, left empty to initialize a bulletPool without graphics
	initSprite: (texture, PIXI) ->
		@spritePool = new PIXI.Container()
		for bullet in @pool
			sprite = new PIXI.Sprite(texture)
			sprite.anchor.set(0.5, 0.5)
			sprite.position = bullet.pos
			sprite.visible = bullet.valid
			bullet.sprite = sprite
			@spritePool.addChild(sprite)
		return @spritePool

	# update the bullets when bullet.valid = true
	# @param world {World}: handle to the world
	update: (world) ->
		for bullet in @pool
			if bullet.valid
				bullet.update(world)
		this

	# find the first empty slot (with an invalid bullet) in the pool
	# @return bullet {Bullet}, bullet.valid means not found
	findFirstEmptySlot: ->
		for bullet in @pool
			if not bullet.valid then return bullet
		return @pool[0]

	destroy: ->
		@pool = null
		@spritePool?.destroy(true)
		@spritePool = null

	copy: (rhs) ->
		for bullet in @pool
			bullet.copyStatus(rhs.pool[bullet.id])
		this

BulletPool.create = (rhs) ->
	bullet = Bullet.copy(rhs.pool[0])
	bulletPool = new BulletPool(rhs.pool.length, bullet)
	return bulletPool.copy(rhs)

module.exports = BulletPool
