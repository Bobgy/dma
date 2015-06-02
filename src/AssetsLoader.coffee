class AssetsLoader
	constructor: (game) ->
		@game = game
		@loader = game.PIXI.loader
		@loader.add('Bullet', 'assets/bullet.png')
		       .add('Bullet2', 'assets/bullet2.png')
		       .add('Servant', 'assets/servant.png')
		       .add('Player', 'assets/bunny.png')
		@loader.once('complete', @onAssetsLoaded)
	load: ->
		@loader.load()
	onAssetsLoaded: =>
		console.log('Assets are loaded.')
		@game.assets = @loader.resources
		@game.run(7)

module.exports = AssetsLoader
