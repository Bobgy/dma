Container = require('./Container.coffee')

# the basic entity of a game
# contains id, position, velocity and its components
# note: remember to check this.valid before updating
class Entity extends Container
  # @param id {string}
  # @param pos {Vec2}: position
  # @param v {Vec2}: velocity
  constructor: (id, @pos, @v) ->
    super(id)
    @valid = true
    @type = 'Entity'
    @faction = -1 #uninitialized faction

  # @param world {Container*}
  # @param parent {Container*}
  # @return this
  update: (world, parent) ->
    return this unless @valid
    @pos.set(@pos.x + @v.x, @pos.y + @v.y)
    return super(world, parent)

  # @param rhs {Entity*}
  # @return this
  copy: (rhs) ->
    super(rhs)
    @pos.copy(rhs.pos)
    @v.copy(rhs.v)
    @valid = rhs.valid
    @faction = rhs.faction
    return this

  # @return {Entity}
  clone: ->
    entity = new Entity(@id, new Vec2(), new Vec2())
    return entity.copy(this)

  # @return this
  destroy: ->
    @pos = null
    @v = null
    return super()

  # init sprite for this entity using texture
  # @param texture {PIXI.Texture}
  # @param PIXI {Module}
  # @return this
  initSprite: (texture, PIXI) ->
    if @components.sprite
      console.log('Error: Entity already has a sprite.')
      console.log(this)
      return this
    sprite = new PIXI.Sprite(texture)
    sprite.anchor.set(0.5, 0.5)
    sprite.position = @pos
    sprite.visible = @valid
    @components.sprite = sprite
    return this

module.exports = Entity
