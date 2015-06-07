BulletEmitter = require('./BulletEmitter.coffee')
Vec2 = require('../../lib/Vec2.coffee')
XOR128 = require('../../../js/xor128.js')

class RandomBulletEmitter extends BulletEmitter
  # @param id {string/integer}
  # @param pos, v, face {Vec2}: position, velocity, facing direction
  # @param args {Args}: additional arguments
  constructor: (id, pos=new Vec2(), v=new Vec2(), face, args) ->
    super(id, pos, v, face, args)
    s = @args.seed
    @prng = new XOR128(s[0], s[1], s[2], s[3])
    @type = 'RandomBulletEmitter'

  preset: ->
    @args =
      bulletSpeed: 4
      interval: 5
      waitTime: 66
      homing: true
      rangeAngle: 120
      poolSize: 64
      seed: [1324, 253525, 31111, 124]
    return this

  fireMore: (world) ->
    pool = world.get('pools').get(@poolID)
    direction = (@prng.random() - 0.5) * @args.rangeAngle * Vec2.degToRad
    @fire(pool, @face.rotate(direction))

  copy: (obj) ->
    super(obj)
    @prng.copy(obj.prng)
    return this

module.exports = RandomBulletEmitter
