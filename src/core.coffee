Vec2 = require('./Vec2.coffee')

EntityFactory = (type, entity) -> type.create(entity)

class World
	w: 960
	h: 600
	constructor: (@PIXI) ->
		if @PIXI?
			@renderer = @PIXI.autoDetectRenderer(@w, @h,
							{backgroundColor : 0x66ccff})

			# create the root of the scene graph
			@stage = new @PIXI.Container()

			# create a texture from an image path
			@texture_player = @PIXI.Texture.fromImage('assets/bunny.png')
			@texture_bullet = @PIXI.Texture.fromImage('assets/bullet.png')
			@texture_servant = @PIXI.Texture.fromImage('assets/servant.png')
			@animate = =>
				requestAnimationFrame(@animate)
				@renderer.render(@stage)
		@tick = 0
		@updating = false
		@players = []
		@entities = []
		@user_count = 0

	addPlayer: (player) =>
		@players.push(player)
		this
	addEntity: (entity) =>
		entity.id = @entities.push(entity) - 1
		this
	update: () =>
		@updating = true
		for entity in @entities
			entity.update(this)
		for player in @players
			player.update(this)
		@tick++
		@updating = false
		this

	importEntity: (entity) =>
		texture = switch entity.type
			when 'Player'
				newEntity = EntityFactory(Player, entity)
				@players.push(newEntity)
				@texture_player
			when 'Bullet'
				console.log('Error Bullet!')
				newEntity = EntityFactory(Bullet, entity)
				@entities.push(newEntity)
				@texture_bullet
			when 'Servant'
				newEntity = EntityFactory(Servant, entity)
				@stage.addChild(newEntity.pool.initSprite(@texture_bullet, @PIXI)) if @PIXI?
				@entities.push(newEntity)
				@texture_servant
		if PIXI?
			sprite = new PIXI.Sprite(texture)
			sprite.anchor.set(0.5, 0.5)
			sprite.position.set(entity.pos.x, entity.pos.y)
			@stage.addChild(sprite)
			newEntity.sprite = sprite

	sync: (players, entities) =>
		@players = []
		for sprite in @stage?.removeChildren()
			sprite.destroy()
		@entities = []
		for entity in entities
			@importEntity(entity)
		for player in players
			@importEntity(player)
		this

	keyAction: (user_id, isDown, keyCode) =>
		@players[user_id].keyState[keyCode] = isDown
	run: (interval) =>
		setInterval(@update, interval)
		@animate?()

class Entity
	constructor: (@pos, @v) ->
		@id = -1 #uninitilized value
		@valid = true
	update: =>
		@pos.copy(@pos.add(@v))
		# @sprite?.position.set(@pos.x, @pos.y)
		this
	copy: (rhs) =>
		@pos.copy(rhs.pos)
		@v.copy(rhs.v)
		@id = rhs.id
		@valid = rhs.valid
	destroy: =>
		@pos = null
		@v = null

class Player extends Entity	
	short_step	:	1.5
	long_step	:	3
	#               Shift,  A,  D,  S,  W,   /
	keys		:	[  16, 65, 68, 83, 87, 191]
	constructor: (@playerID=-1, pos=new Vec2(), @face=new Vec2(), v=new Vec2()) ->
		super(pos, v)
		@keyState = []
		@type = 'Player'
		for key in @keys
			@keyState[key] = false
		@cd = 0
	update: (world) =>
		step = if @keyState[16] then @short_step else @long_step
		@v.x = (@keyState[68] - @keyState[65]) * step
		@v.y = (@keyState[83] - @keyState[87]) * step
		super()
		@pos.x = Math.max(20, @pos.x)
		@pos.y = Math.max(20, @pos.y)
		@pos.x = Math.min(world.w-20, @pos.x)
		@pos.y = Math.min(world.h-20, @pos.y)
		if @cd is 0
			if @keyState[191]
				@cd = 240
				servant = new Servant(@pos, new Vec2(), 120, @face)
				world.addEntity(servant)
		else
			@cd--
		this
	copy: (rhs) =>
		super(rhs)
		@keyState = rhs.keyState
		@cd = rhs.cd
		@playerID = rhs.playerID
		this
	destroy: =>
		@face = null
		@keyState.splice(0, keyState.length)
		@keyState = null
		super()

Player.create = (rhs) ->
	(new Player()).copy(rhs)

class Bullet extends Entity
	collision: true
	constructor: (pos=new Vec2(), v=new Vec2(), @r=0) ->
		super(pos, v)
		@type = 'Bullet'
	update: (world) =>
		super()
		# remove when out of screen
		# if @pos.x < -@r or @pos.y < -@r or @pos.x > world.w + @r or @pos.y > world.h + @r
		if @pos.x < @r or @pos.y < @r or @pos.x > world.w - @r or @pos.y > world.h - @r
			@die()
		this
	clone: => new Bullet(@pos.clone(), @v.clone(), @r)
	die: =>
		@valid = false
		@sprite?.visible = false
	wake: =>
		@valid = true
		@sprite?.visible = true
	copyStatus: (rhs) =>
		@valid = rhs.valid
		@pos.copy(rhs.pos)
		this
	copy: (rhs) =>
		super(rhs)
		@r = rhs.r
		this
	destroy: =>
		@r = null
		super()

Bullet.create = (rhs) ->
	bullet = new Bullet(rhs.pos.clone(), rhs.v.clone(), rhs.r)
	bullet.valid = rhs.valid
	return bullet

# A fixed pool containing bullets of the same type
# int size: the maximum expected number of bullets in the screen
# Bullet bulletPrototype: a prototype used to initialize the pool
# TODO: use a dictionary to store the empty slots
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
	initSprite: (texture, PIXI) =>
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
	update: (world) =>
		for bullet in @pool
			if bullet.valid
				bullet.update(world)
		this

	# find the first empty slot (with an invalid bullet) in the pool
	# @return bullet {Bullet}, bullet.valid means not found
	findFirstEmptySlot: =>
		for bullet in @pool
			if not bullet.valid then return bullet
		return @pool[0]

	destroy: =>
		@pool = null
		@spritePool?.destroy(true)
		@spritePool = null

	copy: (rhs) =>
		for bullet in @pool
			bullet.copyStatus(rhs.pool[bullet.id])
		this

BulletPool.create = (rhs) =>
	bullet = Bullet.copy(rhs.pool[0])
	bulletPool = new BulletPool(rhs.pool.length, bullet)
	return bulletPool.copy(rhs)

# A container that is used to store Object with property 'valid'
# It assumes objects pushed earlier will generall become 'invalid' earlier
# and does garbage collection base on this.
# @content should not be added additional property
# Objects stored will be called the 'destroy()' function when destroyed
class Container
	# @ratio is the garbage collection ratio, default is 2
	# a large ratio will cause garbage collection with a longer time cycle
	constructor: (@ratio=2) ->
		@content = []
	push: (x) =>
		@content.push(x)
	# private
	remove: (beginIndex, length) =>
		temp = @content.splice(beginIndex, length)
		for x in temp
			x.destroy?()

	# Automatic garbage collection inside forEach
	forEach: (f) =>
		firstValid = -1
		for id, x of @content
			if x.valid
				f(x)
				firstValid = id if firstValid == -1 and x.valid
		firstValid = @content.length if firstValid == -1
		if firstValid * @ratio > @content.length
			@remove(0, firstValid)

class Timer
	constructor: (@parent, @wait) ->
	update: (world) =>
		if @wait
			@wait--
		else
			@callback(@parent, world)

class Servant extends Entity
	# @param pos {Vec2}
	# @param v {Vec2}
	# @param cd {int}
	# @param face {Vec2}
	constructor: (pos=new Vec2(), v=new Vec2(), @cd=1000, @face=new Vec2()) ->
		super(new Vec2(pos.x, pos.y), new Vec2(v.x, v.y))
		@timer = 120
		@type = 'Servant'
		@pool = new BulletPool(1, new Bullet(new Vec2(), new Vec2(), 10))

	update: (world) =>
		super()
		if @timer is 0
			@trigger?(world)
		else
			@timer--
		@pool.update(world)
		return this

	trigger: (world) =>
		@timer = @cd
		bullet = @pool.findFirstEmptySlot()
		if not bullet.valid
			bullet.pos.copy(@pos.add(@face))
			bullet.v.copy(@face)
			bullet.wake()
		else
			console.log('BulletPool is full!')
		return this

	copy: (rhs) =>
		super(rhs)
		@cd = rhs.cd
		@face.copy(rhs.face)
		@timer = rhs.timer
		@pool.copy(rhs.pool)
		return this

	destroy: =>
		@pool.destroy()
		@pool = null
		@face = null
		# super()

Servant.create = (rhs) ->
	(new Servant()).copy(rhs)

module.exports = [World, Player, Bullet]