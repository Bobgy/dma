class AssetsLoader
  constructor: (game, fn) ->
    @game = game
    @loader = game.PIXI.loader
    @loader.add('Bullet0', 'assets/bullet0.png')
      .add('Bullet1', 'assets/bullet1.png')
      .add('Servant', 'assets/servant.png')
      .add('Player', 'assets/bunny.png')
    fn = fn.bind(this)
    @loader.once('complete', fn)
  load: -> @loader.load()

module.exports = AssetsLoader
