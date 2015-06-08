Vec2 = require('./Vec2.coffee')
Entity = require('./Entity.coffee')
Servant = require('./Servant.coffee')
SkillSummonServant = require('../scripts/skills/SummonServant.coffee')
Timer = require('./Timer.coffee')

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

  preset: ->
    super()
    args =
      shortStep: 3
      longStep: 6
      #     Shift,  A,  D,  S,  W,   /
      keys: [  16, 65, 68, 83, 87, 191]
      r: 5 # collision radiu
      maxMana: 600
    Utility.setArgs(@args, args)

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


  die: (world) ->
    console.log('Player ', @id, 'died!')
    @valid = false
    @components.sprite?.visible = false
    callback = (world) -> @players[0].wake()
    timer = new Timer({interval: 132, periodic: false},
                      'resurrectTimer', 0, callback)
    world.insert(timer)
    return this

  wake: () ->
    @valid = true
    @components.sprite?.visible = true
    return this

  # @param rhs {Player}
  copy: (rhs) ->
    super(rhs)
    @keyState = rhs.keyState
    @face = rhs.face
    @mana = rhs.mana
    return this

  destroy: (world, parent) ->
    @face = null
    @keyState.splice(0, keyState.length)
    @keyState = null
    return super(world, parent)

  # @param rhs {bullet}
  # @return {bool}
  testCollision: (rhs) ->
    return rhs.valid && (@pos.sub(rhs.pos)).length() <= rhs.r

Player.create = (rhs) ->
  (new Player(rhs.args)).copy(rhs)

module.exports = Player
