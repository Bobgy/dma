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
		player.id = @entities.push(player) - 1

	addEntity: (entity) =>
		entity.id = @entities.push(entity) - 1

	update: () =>
		@updating = true
		for entity in @entities
			entity.update(@w, @h)
		@tick++
		@updating = false

	sync: (players, entities) =>
		@players = players
		@entities = entities
		if @stage?
			@stage.removeChildren()
			for entity in entities
				sprite = switch entity.type
					when 'Player' then new PIXI.Sprite(@texture_player)
					when 'Bullet' then new PIXI.Sprite(@texture_bullet)
				sprite.anchor.set(0.5, 0.5)
				sprite.position.set(entity.pos.x, entity.pos.y)
				entity.sprite = sprite
				@stage.addChild(sprite)

	keyAction: (user_id, isDown, keyCode) =>
		@players[user_id].keyState[keyCode] = isDown

	run: (interval) =>
		setInterval(@update, interval)
		@animate?()

class Vec2
	type: 'Vec2'
	constructor: (@x, @y) ->
	add: (rhs) => new Vec2(@x + rhs.x, @y + rhs.y)
	sub: (rhs) => new Vec2(@x - rhs.x, @y - rhs.y)
	mul: (rhs) => new Vec2(@x * rhs.x, @y * rhs.y)
	scale: (k) => new Vec2(@x * k, @y * k)
	dotMul: (rhs) => @x * rhs.x + @y * rhs.y
	crossMul: (rhs) => @x * rhs.y - @y * rhs.x
	length: => Math.sqrt(@x * @x + @y * @y)
Vec2.zero = new Vec2(0, 0)

class Entity
	constructor: (@pos, @v) ->
		@id = -1 #uninitilized value
		@valid = true
	update: =>
		@pos = @pos.add @v
		@sprite?.position.set(@pos.x, @pos.y)

class Player extends Entity	
	short_step	:	1.5
	long_step	:	3
	keys		:	[16, 65, 68, 83, 87]
	verbose		:	false
	constructor: (@player_id, pos, v=Vec2.zero) ->
		super(pos, v)
		@keyState = []
		@type = 'Player'
		console.log(@keys)
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

class Bullet extends Entity
	collision: true
	constructor: (@r, pos, v) ->
		@type = 'Bullet'
		super(pos, v)
	update: (w, h) =>
		super()
		# remove when out of screen
		if @pos.x < -@r or @pos.y < -@r or @pos.x > @w + @r or @pos.y > @h + @r
			@valid = false
			@sprite?.visible = false

module.exports = [World, Player, Vec2, Bullet]