Vec2 = require('../../Vec2.coffee')
Skill = require('../../Skill.coffee')
Servant = require('../../Servant.coffee')

class SkillSummonServant extends Skill
  cast: (world, parent) ->
    servant = new Servant(parent.pos, new Vec2(), 120, parent.face)
    world.addEntity(parent.playerID, servant)
    if PIXI?
      servant.initSprite(world.assets['Servant'].texture, PIXI)
      world.stage.addChild(servant.components.sprite)
      spritePool = servant.pool.
        initSprite(world.assets['Bullet'].texture, PIXI)
      world.stage.addChild(spritePool)

module.exports = SkillSummonServant
