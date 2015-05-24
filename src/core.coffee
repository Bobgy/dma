class Player
	constructor: (@id, x, y) ->
		@pos = {'x' : x, 'y' : y}
		@keyState = {}

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

	short_step	:	1.5
	long_step	:	3
	
	addPlayer: (player) =>
		@players.push(player)

	update: () =>
		for player in @players
			step = if player.keyState[16] then @short_step else @long_step
			player.pos.y -= step if player.keyState[87]
			player.pos.x -= step if player.keyState[65]
			player.pos.y += step if player.keyState[83]
			player.pos.x += step if player.keyState[68]
			player.sprite?.position.x = player.pos.x
			player.sprite?.position.y = player.pos.y

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

module.exports = [World, Player]