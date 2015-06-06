Vec2 = require('../../Vec2.coffee')
Skill = require('../../Skill.coffee')
Servant = require('../../Servant.coffee')

class SkillSummonServant extends Skill
  constructor: (@id, @coolDown=120, @manaCost=240, @currentTick=0) ->
    @copyable = false

  cast: (world, otherWorld, parent) ->
    servant = new Servant(null, parent.pos.clone(),
                          new Vec2(), 120, parent.face)
    otherWorld.components.eventEmitter.pushEvent(
      'Servant', world.tick + 1, world.tick + 1, servant
    )
    if world.game.io? # TODO change to serverOnly
      world.game.io.emit('Servant', world.tick + 1, otherWorld.id, servant)

SkillSummonServant.init = (world, otherWorld, parent) ->
  world.components.eventEmitter.on('Servant', (tick, servantPrototype) ->
    servant = (new Servant()).copy(servantPrototype)
    @addEntity(servant)
    game = world.game
    if game.PIXI?
      servant.initSprite(world.game.assets['Servant'].texture, game.PIXI)
      world.stage.addChild(servant.components.sprite)
      spritePool = servant.pool.
        initSprite(world.game.assets['Bullet'].texture, game.PIXI)
      world.stage.addChild(spritePool)
    while tick < world.tick
      tick++
      servant.earlyUpdate(this)
      servant.update(this)
  )
  return this

module.exports = SkillSummonServant
