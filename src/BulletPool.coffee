Bullet = require('./Bullet.coffee')
Pool = require('./Pool.coffee')

# A fixed pool containing bullets of the same type
# int size: the maximum expected number of bullets in the screen
# Bullet bulletPrototype: a prototype used to initialize the pool
# TODO: use a queue to store the empty slots

class BulletPool extends Pool
  copy: (rhs) ->
    for bullet in @pool
      bullet.copyStatus(rhs.pool[bullet.id])
            .copyComponents(rhs.pool[bullet.id])
    for name, component of rhs.components
      if component.copyable
        @components[name] = component.clone()
    return this

BulletPool.create = (rhs) -> Pool.create(rhs, Bullet)

module.exports = BulletPool
