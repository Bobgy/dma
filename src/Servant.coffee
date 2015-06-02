Vec2 = require('./Vec2.coffee')
Entity = require('./Entity.coffee')
Bullet = require('./Bullet.coffee')
BulletPool = require('./BulletPool.coffee')
Timer = require('./Timer.coffee')

class Servant extends Entity
  # @param pos {Vec2}
  # @param v {Vec2}
  # @param cd {int}
  # @param face {Vec2}
  constructor: (pos=new Vec2(), v=new Vec2(), @cd=1000, @face=new Vec2()) ->
    super(new Vec2(pos.x, pos.y), new Vec2(v.x, v.y))
    @type = 'Servant'
    bullet = new Bullet(new Vec2(), new Vec2(), 10)
    @pool = new BulletPool(8, bullet)
    @components.fireTimer = new Timer('fireTimer', @cd, @fire, true, -60)

  update: (world) ->
    return this unless @valid
    super(world)
    @pool.update(world)
    return this

  fire: (world, parent) ->
    bullet = parent.pool.findFirstEmptySlot()
    if not bullet.valid
      bullet.pos.copy(parent.pos.add(parent.face))
      bullet.v.copy(parent.face)
      bullet.wake()
    else
      console.log('BulletPool is full!')
    return this

  copy: (rhs) ->
    super(rhs)
    @cd = rhs.cd
    @face.copy(rhs.face)
    @timer = rhs.timer
    @pool.copy(rhs.pool)
    return this

  destroy: ->
    @pool.destroy()
    @pool = null
    @face = null
    # super()

Servant.create = (rhs) ->
  (new Servant()).copy(rhs)

module.exports = Servant
