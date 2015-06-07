Entity = require("../../lib/Entity.coffee")
Vec2 = require("../../lib/Vec2.coffee")
Bullet = require("../../lib/Bullet.coffee")
Pool = require("../../lib/Pool.coffee")
Timer = require("../../lib/Timer.coffee")
Utility = require("../../lib/Utility.coffee")

# A standard BulletEmitter class that emits n-way bullet barrage
# Extend from this class and modify @preset, @fireMore, @copy to customize
class BulletEmitter extends Entity
  # @param id {string/integer}
  # @param pos, v, face {Vec2}: position, velocity, facing direction
  # @param args {Args}: additional arguments
  constructor: (id, pos=new Vec2(), v=new Vec2(), @face, args) ->
    @preset()
    Utility.setArgs(@args, args) if args?
    super(id, pos, v)
    @insert(new Timer('fireTimer', @args.interval, true,
                      @args.interval - @args.waitTime, @fireMore))
    @copyable = true
    @poolID = null # initialize at init()
    @type = 'BulletEmitter'
    @checkSanity()

  preset: ->
    @args =
      bulletSpeed: 3
      interval: 33
      waitTime: 66
      homing: true
      nWay: 5
      deltaAngle: 15
      poolSize: 64
    return this

  init: (world, parent) ->
    if @poolID?
      unless world.get('pools').get(@poolID)?
        throw Error("pool #{@poolID} does not exist")
    else
      bullet = new Bullet(null, new Vec2(), new Vec2(), 10)
      pool = new Pool(null, @args.poolSize, bullet)
      world.get('pools').insert(pool, world)
      pool.active = true
      @poolID = pool.id
      super(world, parent)
    return this

  # @return {boolean}: whether this object passed sanity checking
  checkSanity: ->
    unless @face? and @face.x? and @face.y?
      console.log(this)
      throw Error('Error: @face not set when initializing BulletEmitter')
    return true

  # use homing to toggle whether it targets the enemey
  update: (world, parent) ->
    player = world.players[0]
    if @args.homing and player? and player.valid
      @face = world.players[0].pos.sub(@pos).normalize()
    super(world, parent)

  destroy: (world, parent) ->
    @face = null
    world.get('pools').get(@poolID).active = false if @poolID?
    super(world, parent)
    return this

  # @param pool {Pool}: the bullet pool
  # @param face {Vec2}: the facing direction
  fire: (pool, face=@face) ->
    bullet = pool.findFirstEmptySlot()
    if not bullet.valid
      bullet.pos.copy(@pos.add(face))
      bullet.v = face.scale(@args.bulletSpeed)
      bullet.wake()
    else
      console.log('Error: BulletPool is full!')
      console.log(@components.pool)
    return this

  fireMore: (world) ->
    pool = world.get('pools').get(@poolID)
    delta = Vec2.degToRad * @args.deltaAngle
    n = Math.floor(@args.nWay/2)
    if @args.nWay % 2 == 1
      for i in [-n..n]
        @fire(pool, @face.rotate(delta*i))
    else
      for i in [1..n]
        @fire(pool, @face.rotate(delta*(i-0.5)))
        @fire(pool, @face.rotate(-delta*(i-0.5)))

  copy: (obj) ->
    Utility.setArgs(@args, obj.args)
    @face.copy(obj.face)
    @poolID = obj.poolID
    super(obj)
    return this

module.exports = BulletEmitter
