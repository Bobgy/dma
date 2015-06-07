Container = require('./Container.coffee')

# the basic entity of a game
# contains id, position, velocity and its components
# note: remember to check this.valid before updating
class Entity extends Container
  # @param id {string}
  # @param pos {Vec2}: position
  # @param v {Vec2}: velocity
  # @param faction {integer}
  constructor: (id, @pos, @v, @faction=-1) ->
    super(id)
    @valid = true
    @type = 'Entity'

  init: (world, parent) ->
    if not @components.sprite?
      PIXI = world.game.PIXI
      if PIXI?
        assets = world.game.assets
        if assets[@type]?
          texture = assets[@type].texture
          sprite = @initSprite(texture, PIXI)
          if @type isnt 'Player'
            world.stage.addChild(sprite)
    super(world, parent)
    return this

  # @param world {Container*}
  # @param parent {Container*}
  update: (world, parent) ->
    return this unless @valid
    @pos.set(@pos.x + @v.x, @pos.y + @v.y)
    if @components.sprite?
      @components.sprite.position.set(@pos.x, @pos.y)
    return super(world, parent)

  # @param obj {Entity*}
  copy: (obj) ->
    super(obj)
    @pos.copy(obj.pos)
    @v.copy(obj.v)
    @valid = obj.valid
    @faction = obj.faction
    return this

  # @return {Entity}
  clone: ->
    entity = new Entity(@id, new Vec2(), new Vec2())
    return entity.copy(this)

  destroy: (world, parent) ->
    @pos = null
    @v = null
    return super(world, parent)

  # init sprite for this entity using texture
  # @param texture {PIXI.Texture}
  # @param PIXI {Module}
  # @return {Sprite}
  initSprite: (texture, PIXI) ->
    if @components.sprite?
      console.log(this)
      throw new Error("Entity #{@id} already has a sprite.")
    sprite = new PIXI.Sprite(texture)
    sprite.anchor.set(0.5, 0.5)
    sprite.position = @pos
    sprite.visible = @valid
    @components.sprite = sprite
    return sprite

module.exports = Entity
