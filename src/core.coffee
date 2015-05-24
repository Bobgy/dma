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

		@tick = 0
		@updating = false
		@players = []
		@entity_cnt = 2
		@entities = []
		# ensure entities[0..1] == players[0..1]
		@user_count = 0

	addPlayer: (player) =>
		@players.push(player)
		@entities[player.id] = player

	update: () =>
		@updating = true
		for player in @players
			player.update()
		@tick++
		@updating = false

	sync: (players) =>
		@players = players
		if @stage?
			@stage.removeChildren()
			for player in @players
				sprite = new PIXI.Sprite(@texture)
				sprite.anchor.set(0.5, 0.5)
				sprite.position.set(player.pos.x, player.pos.y)
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

Vec2.zero = new Vec2(0, 0)
keys = [16, 65, 68, 83, 87]

class Entity
	constructor: (@id, @pos, @v) ->
	update: ->
		@pos = @pos.add @v
		@sprite?.position.set(@pos.x, @pos.y)

class Player extends Entity
	short_step	:	1.5
	long_step	:	3
	constructor: (id, pos, v=Vec2.zero) ->
		super(id, pos, v)
		@keyState = []
		for key in keys
			@keyState[key] = false

	update: ->
		step = if @keyState[16] then @short_step else @long_step
		@v.x = (@keyState[68] - @keyState[65]) * step
		@v.y = (@keyState[83] - @keyState[87]) * step
		super()

class Bullet extends Entity
	constructor: (id, pos, v) ->
		super(id, pos, v)
	update: ->
		super()

module.exports = [World, Player, Vec2, Bullet]