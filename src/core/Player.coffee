util = require('./util')
Vec2 = util.Vec2
Entity = require('./Entity')
Servant = require('./Servant')
Timer = require('./Timer')

# a basic player
class Player extends Entity
  # @param id {string}
  # @param pos {Vec2}: position
  # @param v {Vec2}: velocity
  # @param face {Vec2}: facing vector
  constructor: (args, id, pos=new Vec2(), v=new Vec2(), @face=new Vec2()) ->
    super(args, id, pos, v)
    @keyState = []
    @type = 'Player'
    for key in @args.keys
      @keyState[key] = false
    @mana = 0
    @invincible = false

  preset: ->
    super()
    args =
      shortStep: 3
      longStep: 6
      #     Shift,  A,  D,  S,  W,   /
      keys: [  16, 65, 68, 83, 87, 191]
      r: 5 # collision radiu
      maxMana: 540
    util.setArgs(@args, args)

  init: (world, parent) ->
    super(world, parent)
    if world.PIXI?
      @insert(new Player.BlinkWhenInvincible())

  # @param world {Container*}
  # @param parent {Container*}
  update: (world, parent) ->
    return this unless @valid
    @mana = Math.min(@mana + 1, @args.maxMana)
    step = if @keyState[16] then @args.shortStep else @args.longStep
    @v.x = (@keyState[68] - @keyState[65]) * step
    @v.y = (@keyState[83] - @keyState[87]) * step
    super(world, parent)
    @pos.x = Math.max(20, @pos.x)
    @pos.y = Math.max(20, @pos.y)
    @pos.x = Math.min(world.args.w-20, @pos.x)
    @pos.y = Math.min(world.args.h-20, @pos.y)

    return this

  hit: (other, world) ->
    @die(world) unless @invincible

  die: (world) ->
    console.log('Player', @id, 'died!')
    @valid = false
    @components.sprite?.visible = false
    callback = (world) -> @players[0].resurrect(world)
    timer = new Timer({interval: 132, periodic: false},
                      'resurrectTimer', 0, callback)
    world.insert(timer)

    game = world.game
    # broadcast score change
    if game.sockets?
      game.score[world.id^1]++
      game.broadcast('score', game.score)

    return this

  resurrect: (world) ->
    console.log('Player', @id, 'resurrected!')
    @wake()
    @invincible = true
    callback = (world) ->
      @players[0].invincible = false
      console.log('no longer invincible')
    timer = new Timer({interval: 132, periodic: false},
                      'invincibleTimer', 0, callback)
    world.insert(timer)
    return this

  wake: () ->
    @valid = true
    @components.sprite?.visible = true
    return this

  # @param obj {Player}
  copy: (obj) ->
    super(obj)
    @keyState = obj.keyState
    @face = obj.face
    @mana = obj.mana
    @invincible = obj.invincible
    return this

  destroy: (world, parent) ->
    @face = null
    @keyState.splice(0, @keyState.length)
    @keyState = null
    return super(world, parent)

  # @param obj {bullet}
  # @return {bool}
  testCollision: (obj) ->
    return obj.valid && (@pos.sub(obj.pos)).length() <= obj.r

Player.create = (obj) ->
  (new Player(obj.args)).copy(obj)

class BlinkWhenInvincible
  constructor: ->
    @counter = 0
  update: (world, parent) ->
    @counter = (@counter + 1) & 0x1f
    sprite = parent.components.sprite
    if sprite?
      sprite.alpha = if parent.invincible and @counter & 0x10 then 0.5 else 1.0

Player.BlinkWhenInvincible = BlinkWhenInvincible

module.exports = Player
