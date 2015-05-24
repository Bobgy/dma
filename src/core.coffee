class World
	constructor: (@PIXI) ->
		if @PIXI?
			@renderer = @PIXI.autoDetectRenderer(960, 600,
							{backgroundColor : 0x1099bb})

			# create the root of the scene graph
			@stage = new @PIXI.Container()

			# create a texture from an image path
			@texture = @PIXI.Texture.fromImage('assets/bunny.png')
			@animate = =>
				requestAnimationFrame(@animate)
				@renderer.render(@stage)
		@players = []
		@user_count = 0
	
	addPlayer: (player) =>
		@players.push(player)

	update: () =>
		for player in @players
			player.update()

	sync: (players) =>
		@players = players
		if @stage?
			@stage.removeChildren()
			for player in @players
				sprite = new PIXI.Sprite(@texture)
				sprite.anchor.x = 0.5
				sprite.anchor.y = 0.5
				sprite.position.x = player.pos.x
				sprite.position.y = player.pos.y
				player.sprite = sprite
				@stage.addChild(sprite)

	keyAction: (user_id, isDown, keyCode) =>
		@players[user_id].keyState[keyCode] = isDown

	run: (interval) =>
		setInterval(@update, interval)
		@animate?()

class Vec2
	constructor: (@x, @y) ->
	add: (rhs) -> new Vec2(@x + rhs.x, @y + rhs.y)
	sub: (rhs) -> new Vec2(@x - rhs.x, @y - rhs.y)
	mul: (rhs) -> new Vec2(@x * rhs.x, @y * rhs.y)
	scale: (k) -> new Vec2(@x * k, @y * k)
	dotMul: (rhs) -> @x * rhs.x + @y * rhs.y
	crossMul: (rhs) -> @x * rhs.y - @y * rhs.x
	length: -> Math.sqrt(@x * @x + @y * @y)

class Entity
	constructor: (@id, @pos, @world) ->

class Player extends Entity
	short_step	:	1.5
	long_step	:	3
	constructor: (id, pos, world) ->
		@keyState = {}
		super(id, pos, world)
	update: ->
		step = if @keyState[16] then @short_step else @long_step
		@pos.y -= step if @keyState[87]
		@pos.x -= step if @keyState[65]
		@pos.y += step if @keyState[83]
		@pos.x += step if @keyState[68]
		@sprite?.position.set(@pos.x, @pos.y)

class Bullet extends Entity
	constructor: (id, pos, @v, @a) ->
		super(id, pos)

module.exports = [World, Player, Vec2, Bullet]