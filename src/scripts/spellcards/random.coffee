BulletEmitter = require('../../lib/BulletEmitter.coffee')
XOR128 = require('../../../js/xor128.js')

class RandomBulletEmitter extends BulletEmitter
  # @param id {string/integer}
  # @param pos, v, face {Vec2}: position, velocity, facing direction
  # @param args {Args}: additional arguments
  constructor: (id, pos=new Vec2(), v=new Vec2(), face, args) ->
    super(id, pos, v, face, args)
    s = @args.seed
    @prng = new XOR128(s[0], s[1], s[2], s[3])

  preset: ->
    @args =
      bulletSpeed: 4
      interval: 5
      waitTime: 66
      homing: true
      rangeAngle: 120
      poolSize: 64
      seed: [1, 2, 3, 4]

  fireMore: (world) ->
    pool = world.get('pools').get(@poolID)
    direction = (@prng.random() - 0.5) * rangeAngle
    @fire(pool, @face.rotate(direction))
