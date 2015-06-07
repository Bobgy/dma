Entity = require('./Entity.coffee')
Vec2 = require('./Vec2.coffee')
Bullet = require('./Bullet.coffee')
Pool = require('./Pool.coffee')
Timer = require('./Timer.coffee')

class BulletEmitter extends Entity
  bullet_speed: 4
  constructor: (id, pos=new Vec2(), v=new Vec2(),
                @cd=30, @face, @homing=true,
                @n_way=3, @angle_delta=15) ->
    super(id, pos, v)
    fire = @fireMore.bind(this, @n_way, @angle_delta)
    @insert(new Timer('fireTimer', @cd, true, -60, fire))
    @type = 'BulletEmitter'
    @copyable = true
    @poolID = null # initialize at init()
    @checkSanity()

  init: (world, parent) ->
    if @poolID?
      unless world.get('pools').get(@poolID)?
        throw Error("pool #{@poolID} does not exist")
    else
      bullet = new Bullet(null, new Vec2(), new Vec2(), 10)
      pool = new Pool(null, 64, bullet)
      world.get('pools').insert(pool, world)
      pool.active = true
      @poolID = pool.id
      super(world, parent)
    return this

  # @return {boolean}: whether this object passed sanity checking
  checkSanity: ->
    unless @face? and @face.x? and @face.y?
      console.log('Error: @face not set when initializing BulletEmitter')
      console.log(this)
      return false
    return true

  # use homing to toggle whether it targets the enemey
  update: (world, parent) ->
    player = world.players[0]
    if @homing and player? and player.valid
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
      bullet.v = face.scale(@bullet_speed)
      bullet.faction = @faction
      bullet.wake()
    else
      console.log('Error: BulletPool is full!')
      console.log(@components.pool)
    return this

  fireMore: (nWay=1, deltaAngle=15, world) ->
    pool = world.get('pools').get(@poolID)
    delta = Vec2.degToRad * deltaAngle
    n = Math.floor(nWay/2)
    if nWay % 2 == 1
      for i in [-n..n]
        @fire(pool, @face.rotate(delta*i))
    else
      for i in [1..n]
        @fire(pool, @face.rotate(delta*(i-0.5)))
        @fire(pool, @face.rotate(-delta*(i-0.5)))

  copy: (obj) ->
    @cd = obj.cd
    @face.copy(obj.face)
    @homing=obj.homing
    @n_way=obj.n_way
    @angle_delta=obj.angle_delta
    @poolID = obj.poolID
    super(obj)
    fire = @fireMore.bind(this, @n_way, @angle_delta)
    @get('fireTimer').callback = fire
    return this

module.exports = BulletEmitter
