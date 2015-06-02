Vec2 = require('./Vec2.coffee')
Entity = require('./Entity.coffee')

class Bullet extends Entity
	constructor: (pos=new Vec2(), v=new Vec2(), @r=0) ->
		super(pos, v)
		@type = 'Bullet'

	update: (world) ->
		if not @valid then return this
		super()
		# remove when out of screen
		# if @pos.x < -@r or @pos.y < -@r or @pos.x > world.w + @r or @pos.y > world.h + @r
		if @pos.x < @r or @pos.y < @r or @pos.x > world.w - @r or @pos.y > world.h - @r
			@die()
		return this

	clone: ->
		bullet = new Bullet(@pos.clone(), @v.clone(), @r)
		return bullet.copyComponents(this)

	die: ->
		@valid = false
		@components.sprite?.visible = false
		return this

	wake: ->
		@valid = true
		@components.sprite?.visible = true
		return this

	copyStatus: (rhs) ->
		@valid = rhs.valid
		@pos.copy(rhs.pos)
		@v.copy(rhs.v)
		return this

	copy: (rhs) ->
		super(rhs)
		@r = rhs.r
		return this

	destroy: ->
		super()
		@r = null

Bullet.create = (rhs) ->
	bullet = new Bullet(rhs.pos.clone(), rhs.v.clone(), rhs.r)
	bullet.valid = rhs.valid
	return bullet.copyComponents(rhs)

module.exports = Bullet
