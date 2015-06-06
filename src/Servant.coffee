Vec2 = require('./Vec2.coffee')
Entity = require('./Entity.coffee')
Bullet = require('./Bullet.coffee')
Pool = require('./Pool.coffee')
Timer = require('./Timer.coffee')

class Servant extends Entity
  # @param pos {Vec2}
  # @param v {Vec2}
  # @param cd {int}
  # @param face {Vec2}
  constructor: (id, pos=new Vec2(), v=new Vec2(), @cd=1000, @face=new Vec2()) ->
    super(id, pos, v)
    bullet = new Bullet(null, new Vec2(), new Vec2(), 10)
    @pool = new Pool('pool', 8, bullet)
    @components.fireTimer = new Timer('fireTimer', @cd, @fire, true, -60)
    @type = 'Servant'

  # @param world {Container*}
  # @param parent {Container*}
  # @return this
  update: (world, otherWorld, parent) ->
    return this unless @valid
    @pool.update(world, otherWorld, this)
    super(world, otherWorld, parent)
    return this

  # fire only works as a callback function to timer
  # @param world {Container*}
  # @param parent {Container*}
  # @return this
  fire: (world, parent) ->
    bullet = parent.pool.findFirstEmptySlot()
    if not bullet.valid
      bullet.pos.copy(parent.pos.add(parent.face))
      bullet.v.copy(parent.face)
      bullet.faction = parent.faction
      bullet.wake()
    else
      console.log('Error: BulletPool is full!')
      console.log(@pool)
    return this

  # @param rhs {Servant}
  # @return this
  copy: (rhs) ->
    super(rhs)
    @cd = rhs.cd
    @face.copy(rhs.face)
    @timer = rhs.timer
    @pool.copy(rhs.pool)
    return this

  # @return this
  destroy: ->
    @pool.destroy()
    @pool = null
    @face = null
    return super()

Servant.create = (rhs) -> (new Servant()).copy(rhs)

module.exports = Servant
