Vec2 = require('./Vec2.coffee')
Entity = require('./Entity.coffee')
Bullet = require('./Bullet.coffee')
BulletPool = require('./BulletPool.coffee')

class Servant extends Entity
	# @param pos {Vec2}
	# @param v {Vec2}
	# @param cd {int}
	# @param face {Vec2}
	constructor: (pos=new Vec2(), v=new Vec2(), @cd=1000, @face=new Vec2()) ->
		super(new Vec2(pos.x, pos.y), new Vec2(v.x, v.y))
		@timer = 120
		@type = 'Servant'
		@pool = new BulletPool(8, new Bullet(new Vec2(), new Vec2(), 10))

	update: (world) ->
		if not @valid then return this
		super()
		if @timer is 0
			@trigger?(world)
		else
			@timer--
		@pool.update(world)
		return this

	trigger: (world) ->
		@timer = @cd
		bullet = @pool.findFirstEmptySlot()
		if not bullet.valid
			bullet.pos.copy(@pos.add(@face))
			bullet.v.copy(@face)
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
