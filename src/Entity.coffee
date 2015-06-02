class Entity
	constructor: (@pos, @v) ->
		@id = -1 #uninitilized value
		@valid = true
	update: ->
		@pos.copy(@pos.add(@v))
		# @sprite?.position.set(@pos.x, @pos.y)
		this
	copy: (rhs) ->
		@pos.copy(rhs.pos)
		@v.copy(rhs.v)
		@id = rhs.id
		@valid = rhs.valid
	destroy: ->
		@pos = null
		@v = null

module.exports = Entity
