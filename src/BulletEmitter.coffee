Entity = require('./Entity.coffee')
Vec2 = require('./Vec2.coffee')
Bullet = require('./Bullet.coffee')
Pool = require('./Pool.coffee')
Timer = require('./Timer.coffee')

class BulletEmitter extends Entity
  bullet_speed: 4

  constructor: (id, pos=new Vec2(), v=new Vec2(), @cd=30, @face) ->
    super(id, pos, v)
    bullet = new Bullet(null, new Vec2(), new Vec2(), 10)
    @insert(new Pool('pool', 10, bullet))
    @insert(new Timer('fireTimer', @cd, @fire, true, -60))
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

  # inherits update: (world, parent)

  destroy: (world, parent) ->
    @face = null
    super(world, parent)
    return this

  # fire only works as a callback function to timer
  # @param world {World}
  # @param parent {Container*}
  fire: (world, parent) ->
    bullet = parent.components.pool.findFirstEmptySlot()
    if not bullet.valid
      bullet.pos.copy(parent.pos.add(parent.face))
      bullet.v = parent.face.scale(parent.bullet_speed)
      bullet.faction = parent.faction
      bullet.wake()
    else
      console.log('Error: BulletPool is full!')
      console.log(parent.components.pool)
    return this

  copy: (obj) ->
    super(obj)
    @cd = obj.cd
    @face.copy(obj.face)

module.exports = BulletEmitter
