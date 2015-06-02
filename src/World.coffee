Vec2 = require('./Vec2.coffee')
Entity = require('./Entity.coffee')
Bullet = require('./Bullet.coffee')
BulletPool = require('./BulletPool.coffee')
Servant = require('./Servant.coffee')
Player = require('./Player.coffee')

EntityFactory = (type, entity) -> type.create(entity)

class World
	w: 960
	h: 600
	constructor: (@PIXI) ->
		if @PIXI?
			@renderer = @PIXI.autoDetectRenderer(@w, @h,
							{backgroundColor : 0x66ccff})
			# create the root of the scene graph
			@stage = new @PIXI.Container()
			@animate = => @renderer.render(@stage)
		@tick = 0
		@updating = false
		@players = []
		@factions = []
		@user_count = 0

	addPlayer: (player) ->
		@players.push(player)
		@factions.push([])
		this
	addEntity: (faction, entity) ->
		entity.id = @factions[faction].push(entity) - 1
		this
	update: () =>
		@updating = true
		for entities in @factions
			for entity in entities
				entity.update(this)
		for player in @players
			player.update(this)
			if player.valid
				for id in [0..@factions.length-1]
					entities = @factions[id]
					if player.playerID isnt id
						for servant in entities
							for bullet in servant.pool.pool
								if player.testCollision(bullet)
									player.die()
									bullet.die()
		@tick++
		if @PIXI? then requestAnimationFrame(@animate)
		@updating = false
		this

	importEntity: (container, entity) ->
		newEntity = EntityFactory(eval(entity.type), entity)
		if entity.type is 'Servant'
			@stage.addChild(newEntity.pool.initSprite(@assets['Bullet'].texture, PIXI))
		texture = @assets[entity.type].texture
		container.push(newEntity)
		if PIXI?
			sprite = new PIXI.Sprite(texture)
			sprite.anchor.set(0.5, 0.5)
			sprite.position = newEntity.pos
			sprite.visible = newEntity.valid
			@stage.addChild(sprite)
			newEntity.sprite = sprite

	sync: (players, factions) ->
		@players = []
		for sprite in @stage?.removeChildren()
			sprite.destroy()
		@factions = []
		for entities in factions
			id = @factions.push([])
			for entity in entities
				@importEntity(@factions[id-1], entity)
		for player in players
			@importEntity(@players, player)
		this

	keyAction: (user_id, isDown, keyCode) ->
		@players[user_id].keyState[keyCode] = isDown
	run: (interval) ->
		setInterval(@update, interval)

# A container that is used to store Object with property 'valid'
# It assumes objects pushed earlier will generall become 'invalid' earlier
# and does garbage collection base on this.
# @content should not be added additional property
# Objects stored will be called the 'destroy()' function when destroyed
class Container
	# @ratio is the garbage collection ratio, default is 2
	# a large ratio will cause garbage collection with a longer time cycle
	constructor: (@ratio=2) ->
		@content = []
	push: (x) ->
		@content.push(x)
	# private
	remove: (beginIndex, length) ->
		temp = @content.splice(beginIndex, length)
		for x in temp
			x.destroy?()

	# Automatic garbage collection inside forEach
	forEach: (f) ->
		firstValid = -1
		for id, x of @content
			if x.valid
				f(x)
				firstValid = id if firstValid == -1 and x.valid
		firstValid = @content.length if firstValid == -1
		if firstValid * @ratio > @content.length
			@remove(0, firstValid)

class Timer
	constructor: (@parent, @wait) ->
	update: (world) ->
		if @wait
			@wait--
		else
			@callback(@parent, world)

module.exports = World
