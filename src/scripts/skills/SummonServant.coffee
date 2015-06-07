Vec2 = require('../../lib/Vec2.coffee')
Skill = require('../../lib/Skill.coffee')
Servant = require('../../lib/Servant.coffee')

class SkillSummonServant extends Skill
  constructor: (@id, @coolDown=120, @manaCost=240, @currentTick=0) ->
    @copyable = false

  cast: (world, parent) ->
    servant = new Servant(null, parent.pos.clone(),
                          new Vec2(), parent.face)
    world.game.getWorld(world.id^1).get('eventEmitter').pushEvent(
      'Servant', world.tick + 1, world.tick + 1, servant
    )
    if world.game.io? # TODO change to serverOnly
      world.game.io.emit('Servant', world.tick + 1, world.id^1, servant)

SkillSummonServant.init = (world, parent) ->
  world.get('eventEmitter').on('Servant', (tick, servantPrototype) ->
    servant = (new Servant()).copy(servantPrototype)
    @addEntity(servant)
    console.log("New servant:", servant.type)
    while tick < @tick
      tick++
      servant.earlyUpdate(this, @components.enemies)
      servant.update(this, @components.enemies)
  )
  return this

module.exports = SkillSummonServant
