class AssetsLoader
  constructor: (game, fn) ->
    @game = game
    @loader = game.PIXI.loader
    @loader.add('Bullet', 'assets/bullet.png')
           .add('Bullet2', 'assets/bullet2.png')
           .add('Servant', 'assets/servant.png')
           .add('Player', 'assets/bunny.png')
    fn = fn.bind(this)
    @loader.once('complete', fn)
  load: -> @loader.load()

module.exports = AssetsLoader
