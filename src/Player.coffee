Vec2 = require('./Vec2.coffee')
Entity = require('./Entity.coffee')
Servant = require('./Servant.coffee')

class Player extends Entity
	short_step	:	1.5
	long_step	:	3
	#      Shift,  A,  D,  S,  W,   /
	keys : [  16, 65, 68, 83, 87, 191]
	r: 5 # the collision radius
	constructor: (@playerID=-1, pos=new Vec2(), @face=new Vec2(), v=new Vec2()) ->
		super(pos, v)
		@keyState = []
		@type = 'Player'
		for key in @keys
			@keyState[key] = false
		@cd = 0
	update: (world) ->
		if not @valid then return this
		step = if @keyState[16] then @short_step else @long_step
		@v.x = (@keyState[68] - @keyState[65]) * step
		@v.y = (@keyState[83] - @keyState[87]) * step
		super(world)
		@pos.x = Math.max(20, @pos.x)
		@pos.y = Math.max(20, @pos.y)
		@pos.x = Math.min(world.w-20, @pos.x)
		@pos.y = Math.min(world.h-20, @pos.y)
		if @cd is 0
			if @keyState[191]
				@cd = 240
				servant = new Servant(@pos, new Vec2(), 120, @face)
				world.addEntity(@playerID, servant)
				if PIXI?
					servant.initSprite(world.assets['Servant'].texture, PIXI)
					world.stage.addChild(servant.components.sprite)
					spritePool = servant.pool.initSprite(world.assets['Bullet'].texture, PIXI)
					world.stage.addChild(spritePool)
		else
			@cd--
		this
	die: ->
		@valid = false
		@components.sprite?.visible = false
	copy: (rhs) ->
		super(rhs)
		@keyState = rhs.keyState
		@cd = rhs.cd
		@playerID = rhs.playerID
		@face = rhs.face
		this
	destroy: ->
		@face = null
		@keyState.splice(0, keyState.length)
		@keyState = null
		super()
	testCollision: (rhs) ->
		return rhs.valid && (@pos.sub(rhs.pos)).length() < @r + rhs.r

Player.create = (rhs) ->
	(new Player()).copy(rhs)

module.exports = Player
