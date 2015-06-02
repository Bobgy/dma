class Entity
	constructor: (@pos, @v) ->
		@id = -1 #uninitilized value
		@valid = true
		@components = Object.create(null)
	update: (world) ->
		@pos.copy(@pos.add(@v))
		for component in @components
			component.update?(world, this)
		this
	copy: (rhs) ->
		@pos.copy(rhs.pos)
		@v.copy(rhs.v)
		@id = rhs.id
		@valid = rhs.valid
	clone: (rhs) ->
		new Entity(@pos.clone(), @v.clone())
	copyComponents: (rhs) ->
		for key, value of rhs.components
			if value.copyable
				@components[key] = value.clone()
		return this
	destroy: ->
		@pos = null
		@v = null
		for component in @components
			component.destroy?()
		@components = null
	initSprite: (texture, PIXI) ->
		if @components.sprite
			console.log('Error: Entity already has a sprite.')
			return this
		sprite = new PIXI.Sprite(texture)
		sprite.anchor.set(0.5, 0.5)
		sprite.position = @pos
		sprite.visible = @valid
		@components.sprite = sprite
		return this

module.exports = Entity
