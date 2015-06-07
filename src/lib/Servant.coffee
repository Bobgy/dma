Vec2 = require('./Vec2.coffee')
Entity = require('./Entity.coffee')
Utility = require('./Utility.coffee')
BulletEmitter = require("../scripts/patterns/BulletEmitter.coffee")
RandomBulletEmitter = require("../scripts/patterns/RandomBulletEmitter.coffee")

class Servant extends Entity
  # @param pos {Vec2}
  # @param v {Vec2}
  # @param cd {int}
  # @param face {Vec2}
  # @param timeToLive {int(tick)}
  constructor: (id, pos=new Vec2(), v=new Vec2(),
                @face=new Vec2(), @timeToLive = 666
                , random=false) ->
    super(id, pos, v)
    if random?
      emitter = unless random
        new BulletEmitter('emitter', @pos, null, @face.clone())
      else
        new RandomBulletEmitter('emitter', @pos, null, @face.clone())
      @insert(emitter)
    @type = 'Servant'

  # inherits init: (world, parent) ->

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
    #unless @components.emitter?
    #  type = eval(obj.components.emitter.type)
    #  emitter = new type('emitter', obj.pos, null, obj.face.clone())
    #  @insert(emitter)
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
