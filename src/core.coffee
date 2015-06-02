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
			@animate = => @renderer.render(@stage)
		@tick = 0
		@updating = false
		@players = []
		@factions = []
		@user_count = 0

	addPlayer: (player) ->
		@players.push(player)
		@factions.push([])
		this
	addEntity: (faction, entity) ->
		entity.id = @factions[faction].push(entity) - 1
		this
	update: () =>
		@updating = true
		for entities in @factions
			for entity in entities
				entity.update(this)
		for player in @players
			player.update(this)
			if player.valid
				for id in [0..@factions.length-1]
					entities = @factions[id]
					if player.playerID isnt id
						for servant in entities
							for bullet in servant.pool.pool
								if player.testCollision(bullet)
									player.die()
									bullet.die()
		@tick++
		if @PIXI? then requestAnimationFrame(@animate)
		@updating = false
		this

	importEntity: (container, entity) ->
		newEntity = EntityFactory(eval(entity.type), entity)
		if entity.type is 'Servant'
			@stage.addChild(newEntity.pool.initSprite(@assets['Bullet'].texture, PIXI))
		texture = @assets[entity.type].texture
		container.push(newEntity)
		if PIXI?
			sprite = new PIXI.Sprite(texture)
			sprite.anchor.set(0.5, 0.5)
			sprite.position = newEntity.pos
			sprite.visible = newEntity.valid
			@stage.addChild(sprite)
			newEntity.sprite = sprite

	sync: (players, factions) ->
		@players = []
		for sprite in @stage?.removeChildren()
			sprite.destroy()
		@factions = []
		for entities in factions
			id = @factions.push([])
			for entity in entities
				@importEntity(@factions[id-1], entity)
		for player in players
			@importEntity(@players, player)
		this

	keyAction: (user_id, isDown, keyCode) ->
		@players[user_id].keyState[keyCode] = isDown
	run: (interval) ->
		setInterval(@update, interval)

class Entity
	constructor: (@pos, @v) ->
		@id = -1 #uninitilized value
		@valid = true
	update: ->
		@pos.copy(@pos.add(@v))
		# @sprite?.position.set(@pos.x, @pos.y)
		this
	copy: (rhs) ->
		@pos.copy(rhs.pos)
		@v.copy(rhs.v)
		@id = rhs.id
		@valid = rhs.valid
	destroy: ->
		@pos = null
		@v = null

class Player extends Entity
	short_step	:	1.5
	long_step	:	3
	#      Shift,  A,  D,  S,  W,   /
	keys : [  16, 65, 68, 83, 87, 191]
	r: 5 # the collision radius
	constructor: (@playerID=-1, pos=new Vec2(), @face=new Vec2(), v=new Vec2()) ->
		super(pos, v)
		@keyState = []
		@type = 'Player'
		for key in @keys
			@keyState[key] = false
		@cd = 0
	update: (world) ->
		if not @valid then return this
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
				world.addEntity(@playerID, servant)
				if PIXI?
					sprite = new PIXI.Sprite(world.assets['Servant'].texture)
					sprite.anchor.set(0.5, 0.5)
					sprite.position = servant.pos
					servant.sprite = sprite
					world.stage.addChild(sprite)
					spritePool = servant.pool.initSprite(world.assets['Bullet'].texture, PIXI)
					world.stage.addChild(spritePool)
		else
			@cd--
		this
	die: ->
		@valid = false
		@sprite?.visible = false
	copy: (rhs) ->
		super(rhs)
		@keyState = rhs.keyState
		@cd = rhs.cd
		@playerID = rhs.playerID
		@face = rhs.face
		this
	destroy: ->
		@face = null
		@keyState.splice(0, keyState.length)
		@keyState = null
		super()
	testCollision: (rhs) ->
		return rhs.valid && (@pos.sub(rhs.pos)).length() < @r + rhs.r

Player.create = (rhs) ->
	(new Player()).copy(rhs)

class Bullet extends Entity
	constructor: (pos=new Vec2(), v=new Vec2(), @r=0) ->
		super(pos, v)
		@type = 'Bullet'
	update: (world) ->
		if not @valid then return this
		super()
		# remove when out of screen
		# if @pos.x < -@r or @pos.y < -@r or @pos.x > world.w + @r or @pos.y > world.h + @r
		if @pos.x < @r or @pos.y < @r or @pos.x > world.w - @r or @pos.y > world.h - @r
			@die()
		this
	clone: -> new Bullet(@pos.clone(), @v.clone(), @r)
	die: ->
		@valid = false
		@sprite?.visible = false
	wake: ->
		@valid = true
		@sprite?.visible = true
	copyStatus: (rhs) ->
		@valid = rhs.valid
		@pos.copy(rhs.pos)
		@v.copy(rhs.v)
		this
	copy: (rhs) ->
		super(rhs)
		@r = rhs.r
		this
	destroy: ->
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
	push: (x) ->
		@content.push(x)
	# private
	remove: (beginIndex, length) ->
		temp = @content.splice(beginIndex, length)
		for x in temp
			x.destroy?()

	# Automatic garbage collection inside forEach
	forEach: (f) ->
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
	update: (world) ->
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
		@pool = new BulletPool(8, new Bullet(new Vec2(), new Vec2(), 10))

	update: (world) ->
		if not @valid then return this
		super()
		if @timer is 0
			@trigger?(world)
		else
			@timer--
		@pool.update(world)
		return this

	trigger: (world) ->
		@timer = @cd
		bullet = @pool.findFirstEmptySlot()
		if not bullet.valid
			bullet.pos.copy(@pos.add(@face))
			bullet.v.copy(@face)
			bullet.wake()
		else
			console.log('BulletPool is full!')
		return this

	copy: (rhs) ->
		super(rhs)
		@cd = rhs.cd
		@face.copy(rhs.face)
		@timer = rhs.timer
		@pool.copy(rhs.pool)
		return this

	destroy: ->
		@pool.destroy()
		@pool = null
		@face = null
		# super()

Servant.create = (rhs) ->
	(new Servant()).copy(rhs)

module.exports = [World, Player, Bullet]
