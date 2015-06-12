"use strict"

Core = require('../lib')

class GUI extends Core.Container
  # @param args {Object}
  #   pos {x, y}: position
  # @inheritDoc
  constructor: (args, id, @PIXI) ->
    super(args, id)
    @stage = new @PIXI.Container()
    @stage.position.set(@args.pos.x, @args.pos.y)

  preset: ->
    super()
    args =
      pos:
        x: 0
        y: 0
    Core.util.setArgs(@args, args)

  destroy: (game, parent) ->
    super(game, parent)
    @stage.destroy()
    return this

# a scoreboard that displays its game.score {Array(2)}
class ScoreBoard extends GUI
  constructor: (args, id, PIXI) ->
    super(args, id, PIXI)
    style =
      font: ' 32px Arial'
      fill: '#ffffff'
      align: 'center'
      stroke: '#aaaaaa'
      strokeThickness: 0
    @leftScore = 0
    @rightScore = 0
    @textSprite = new PIXI.Text('Score  0 : 0', style)
    @stage.addChild(@textSprite)
    @game = null

  init: (game, parent) ->
    super(game, parent)
    @game = game
    parent.stage.addChild(@stage)
    return this

  update: (game, parent) ->
    @textSprite.text = 'Score  ' + game.score[0] + ' : ' + game.score[1]
    return this

  destroy: (game, parent) ->
    children = @stage.removeChildren()
    for child in children
      child.destroy()
    super(game, parent)
    @game = null
    return this

module.exports = {
  GUI
  ScoreBoard
}
