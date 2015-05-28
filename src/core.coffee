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
			entity.update(@w, @h)
		for player in @players
			player.update(@w, @h)
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

Vec2.zero = new Vec2(0, 0)

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
	keys		:	[16, 65, 68, 83, 87]
	verbose		:	false

	constructor: (@playerID, pos, v=Vec2.zero) ->
		super(pos, v)
		@keyState = []
		@type = 'Player'
		for key in @keys
			@keyState[key] = false
		@cd = 0

	update: (w, h) =>
		step = if @keyState[16] then @short_step else @long_step
		@v.x = (@keyState[68] - @keyState[65]) * step
		@v.y = (@keyState[83] - @keyState[87]) * step
		super()
		@pos.x = Math.max(20, @pos.x)
		@pos.y = Math.max(20, @pos.y)
		@pos.x = Math.min(w-20, @pos.x)
		@pos.y = Math.min(h-20, @pos.y)
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

	constructor: (@r=0, pos=Vec2.zero, v=Vec2.zero) ->
		@type = 'Bullet'
		super(pos, v)
	
	update: (w, h) =>
		super()
		# remove when out of screen
		if @pos.x < -@r or @pos.y < -@r or @pos.x > @w + @r or @pos.y > @h + @r
			@valid = false
			@sprite?.visible = false
		this
	
	sync: (rhs) =>
		super(rhs)
		@r = rhs.r
		this

module.exports = [World, Player, Vec2, Bullet]