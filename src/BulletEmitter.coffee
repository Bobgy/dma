Entity = require('./Entity.coffee')
Vec2 = require('./Vec2.coffee')
Bullet = require('./Bullet.coffee')
Pool = require('./Pool.coffee')
Timer = require('./Timer.coffee')

class BulletEmitter extends Entity
  bullet_speed: 4
  constructor: (id, pos=new Vec2(), v=new Vec2(),
                @cd=30, @face, @homing=true,
                @n_way=3,@angle_delta=15) ->
    super(id, pos, v)
    bullet = new Bullet(null, new Vec2(), new Vec2(), 10)
    @insert(new Pool('pool', 64, bullet))
    fire = @fireMore.bind(this, @n_way, @angle_delta)
    @insert(new Timer('fireTimer', @cd, true, -60, fire))
    @type = 'BulletEmitter'
    @copyable = true
    @checkSanity()

  # @return {boolean}: whether this object passed sanity checking
  checkSanity: ->
    unless @face?
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
    super(world, parent)
    return this

  # @param world {World}
  # @param face {Vec2}: the facing direction
  fire: (world, face=@face) ->
    bullet = @components.pool.findFirstEmptySlot()
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
    delta = Vec2.degToRad*deltaAngle
    n = Math.floor(nWay/2)
    if nWay % 2 == 1
      for i in [-n..n]
        @fire(world, @face.rotate(delta*i))
    else
      for i in [1..n]
        @fire(world, @face.rotate(delta*(i-0.5)))
        @fire(world, @face.rotate(-delta*(i-0.5)))

  copy: (obj) ->
    super(obj)
    @cd = obj.cd
    @face.copy(obj.face)

module.exports = BulletEmitter
