Vec2 = require('./Vec2.coffee')
Entity = require('./Entity.coffee')
Utility = require('./Utility.coffee')
BulletEmitter = require('./BulletEmitter.coffee')

class Servant extends Entity
  # @param pos {Vec2}
  # @param v {Vec2}
  # @param cd {int}
  # @param face {Vec2}
  # @param timeToLive {int(tick)}
  constructor: (id, pos=new Vec2(), v=new Vec2(),
                @face=new Vec2(), @timeToLive = 666) ->
    super(id, pos, v)
    @insert(new BulletEmitter('bulletEmitter', @pos, null, null, @face.clone()))
    @type = 'Servant'

  # inehrits init: (world, parent)
  
  # @param world {Container*}
  # @param parent {Container*}
  update: (world, parent) ->
    return this unless @valid
    super(world, parent)
    @timeToLive--
    @destroy(world, world.components.enemies) if @timeToLive <= 0
    return this

  # @param obj {Servant}
  copy: (obj) ->
    super(obj)
    @face.copy(obj.face)
    @timeToLive = obj.timeToLive
    return this

  # @param world {World}
  destroy: (world, parent) ->
    @face = null
    if @components.sprite?
      Utility.destroyDisplayObject(@components.sprite)
      delete @components.sprite
    super(world, parent)
    return this

Servant.create = (obj) -> (new Servant()).copy(obj)

module.exports = Servant
