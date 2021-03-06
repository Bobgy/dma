Entity = require('./Entity')
util = require('./util')
Vec2 = util.Vec2
BulletEmitter = require("../scripts/patterns/BulletEmitter")
RandomBulletEmitter = require("../scripts/patterns/RandomBulletEmitter")

class Servant extends Entity
  # @param pos {Vec2}
  # @param v {Vec2}
  # @param cd {int}
  # @param face {Vec2}
  # @param timeToLive {int(tick)}
  constructor: (args, id, pos=new Vec2(), v=new Vec2(),
                @face=new Vec2()) ->
    super(args, id, pos, v)
    emitter = unless @args.random
      new BulletEmitter(null, 'emitter', @pos, null, @face.clone())
    else
      new RandomBulletEmitter(null, 'emitter', @pos, null, @face.clone())
    @insert(emitter)
    @args.timeToLive
    @type = 'Servant'

  preset: ->
    super()
    args =
      timeToLive: 666
      random: false
    util.setArgs(@args, args)

  # inherits init: (world, parent) ->

  # @param world {Container*}
  # @param parent {Container*}
  update: (world, parent) ->
    return this unless @valid
    super(world, parent)
    @args.timeToLive--
    @destroy(world, world.components.enemies) if @args.timeToLive <= 0
    return this

  # @param obj {Servant}
  copy: (obj) ->
    #unless @components.emitter?
    #  type = eval(obj.components.emitter.type)
    #  emitter = new type('emitter', obj.pos, null, obj.face.clone())
    #  @insert(emitter)
    super(obj)
    @face.copy(obj.face)
    return this

  # @param world {World}
  destroy: (world, parent) ->
    @face = null
    super(world, parent)
    return this

Servant.create = (obj) -> (new Servant(obj.args)).copy(obj)

module.exports = Servant
