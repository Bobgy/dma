util = require('../../core/util')
Vec2 = util.Vec2
Skill = require('../../core/Skill')
Servant = require('../../core/Servant')

class SkillSummonServant extends Skill
  constructor: (args, id) ->
    super(args, id)
    @copyable = false

  cast: (world, parent) ->
    random = Math.random() < 0.5
    servant = new Servant({random: random}, null, parent.pos.clone(),
                          new Vec2(), parent.face)#, Math.random() > 0.5)
    world.game.getWorld(world.id^1).get('eventEmitter').pushEvent(
      'Servant', world.tick + 1, world.tick + 1, servant
    )
    game = world.game
    if game.sockets? # TODO change to serverOnly
      game.broadcast('Servant', world.tick + 1, world.id ^ 1, servant)

SkillSummonServant.init = (world, parent) ->
  world.get('eventEmitter').on('Servant', (tick, servantPrototype) ->
    servant = (new Servant(servantPrototype.args)).copy(servantPrototype)
    @addEntity(servant)
    if world.verbose
      console.log("New servant:")
      console.log(servant)
    while tick < @tick
      tick++
      servant.earlyUpdate(this, @components.enemies)
      servant.update(this, @components.enemies)
  )
  return this

module.exports = SkillSummonServant
