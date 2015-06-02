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
		this
	clone: -> new Bullet(@pos.clone(), @v.clone(), @r)
	die: ->
		@valid = false
		@sprite?.visible = false
	wake: ->
		@valid = true
		@sprite?.visible = true
	copyStatus: (rhs) ->
		@valid = rhs.valid
		@pos.copy(rhs.pos)
		@v.copy(rhs.v)
		this
	copy: (rhs) ->
		super(rhs)
		@r = rhs.r
		this
	destroy: ->
		@r = null
		super()

Bullet.create = (rhs) ->
	bullet = new Bullet(rhs.pos.clone(), rhs.v.clone(), rhs.r)
	bullet.valid = rhs.valid
	return bullet

module.exports = Bullet
