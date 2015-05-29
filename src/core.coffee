EntityFactory = (type, entity) ->
	(new type()).sync(entity)

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
				newEntity = EntityFactory(Bullet, entity)
				@entities.push(newEntity)
				@texture_bullet
			when 'Servant'
				newEntity = EntityFactory(Servant, entity)
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
		@entities = []
		@stage?.removeChildren()
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

class Vec2
	type: 'Vec2'
	constructor: (@x = 0, @y = 0) ->
	add: (rhs) => new Vec2(@x + rhs.x, @y + rhs.y)
	sub: (rhs) => new Vec2(@x - rhs.x, @y - rhs.y)
	mul: (rhs) => new Vec2(@x * rhs.x, @y * rhs.y)
	scale: (k) => new Vec2(@x * k, @y * k)
	dotMul: (rhs) => @x * rhs.x + @y * rhs.y
	crossMul: (rhs) => @x * rhs.y - @y * rhs.x
	length: => Math.sqrt(@x * @x + @y * @y)
	sync: (rhs) =>
		@x = rhs.x
		@y = rhs.y
		this
	clone: =>
		new Vec2(@x, @y)

class Entity
	constructor: (@pos, @v) ->
		@id = -1 #uninitilized value
		@valid = true
	update: =>
		@pos = @pos.add(@v)
		@sprite?.position.set(@pos.x, @pos.y)
		this
	sync: (rhs) =>
		@pos = new Vec2()
		@v = new Vec2()
		@pos.sync(rhs.pos)
		@v.sync(rhs.v)
		@id = rhs.id
		@valid = rhs.valid
		this

class Player extends Entity	
	short_step	:	1.5
	long_step	:	3
	#               Shift,  A,  D,  S,  W,   /
	keys		:	[  16, 65, 68, 83, 87, 191]
	verbose		:	false
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
		if @verbose then console.log(@pos)
		this
	sync: (rhs) =>
		super(rhs)
		@keyState = rhs.keyState
		@cd = rhs.cd
		@playerID = rhs.playerID
		this

class Bullet extends Entity
	collision: true
	constructor: (@r=0, pos=new Vec2(), v=new Vec2()) ->
		@type = 'Bullet'
		super(pos, v)
	update: (world) =>
		super()
		# remove when out of screen
		# if @pos.x < -@r or @pos.y < -@r or @pos.x > world.w + @r or @pos.y > world.h + @r
		if @pos.x < @r or @pos.y < @r or @pos.x > world.w - @r or @pos.y > world.h - @r
			@valid = false
			@sprite?.visible = false
		this
	sync: (rhs) =>
		super(rhs)
		@r = rhs.r
		this

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
	constructor: (pos=new Vec2(), v=new Vec2(), @cd=1000, @face=new Vec2()) ->
		super(new Vec2(pos.x, pos.y), new Vec2(v.x, v.y))
		@timer = 120
		@type = 'Servant'
	update: (world) =>
		super()
		if @timer is 0
			@trigger?(world)
		else
			@timer--
		return this
	trigger: (world) =>
		@timer = @cd
		bullet = new Bullet(10, @pos.add(@face), @face)
		world.addEntity(bullet)
		return this
	sync: (rhs) =>
		super(rhs)
		@cd = rhs.cd
		@face = rhs.face
		@timer = rhs.timer
		return this

module.exports = [World, Player, Vec2, Bullet]