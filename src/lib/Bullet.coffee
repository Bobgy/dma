Vec2 = require('./Vec2.coffee')
Entity = require('./Entity.coffee')

class Bullet extends Entity
  # @param id {string}
  # @param pos {Vec2}: position
  # @param v {Vec2}: velocity
  # @param r {float}: radius
  constructor: (id, pos=new Vec2(), v=new Vec2(), @r=0) ->
    super(id, pos, v)
    @type = 'Bullet'

  update: (world, parent) ->
    return this unless @valid
    super(world, parent)
    # remove when out of screen
    if  @pos.x < @r or
        @pos.y < @r or
        @pos.x > world.w - @r or
        @pos.y > world.h - @r
      @die()
    else
      for player in world.players
        if  player.valid and
            player.faction isnt @faction and
            player.testCollision(this)
          player.die(world)
          @die()
          break
    return this

  # @return {Bullet}
  clone: ->
    bullet = new Bullet(@id, @pos.clone(), @v.clone(), @r)
    bullet.id = @id
    return bullet.copyComponents(this)

  die: ->
    @valid = false
    @components.sprite?.visible = false
    return this

  wake: ->
    @valid = true
    @components.sprite?.visible = true
    return this

  # @param rhs {Bullet}
  copyStatus: (rhs) ->
    @valid = rhs.valid
    @pos.copy(rhs.pos)
    @v.copy(rhs.v)
    return this

  # @param rhs {Bullet}
  copy: (rhs) ->
    super(rhs)
    @r = rhs.r
    return this

  # inherits `destroy: ->`

Bullet.create = (rhs) ->
  bullet = new Bullet(rhs.id, rhs.pos.clone(), rhs.v.clone(), rhs.r)
  bullet.valid = rhs.valid
  return bullet.copyComponents(rhs)

module.exports = Bullet
