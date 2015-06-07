class Vec2
  constructor: (@x = 0, @y = 0) ->
  add: (rhs) -> new Vec2(@x + rhs.x, @y + rhs.y)
  sub: (rhs) -> new Vec2(@x - rhs.x, @y - rhs.y)
  mul: (rhs) -> new Vec2(@x * rhs.x, @y * rhs.y)
  scale: (k) -> new Vec2(@x * k, @y * k)
  dotMul: (rhs) -> @x * rhs.x + @y * rhs.y
  crossMul: (rhs) -> @x * rhs.y - @y * rhs.x
  length: -> Math.sqrt(@x * @x + @y * @y)
  normalize: (len=1) -> @scale(len/@length())
  rotate: (rad) -> # counter clockwise rotation
    c = Math.cos(rad)
    s = Math.sin(rad)
    new Vec2(@x*c-@y*s, @x*s+@y*c)
  sync: (rhs) ->
    @x = rhs.x
    @y = rhs.y
    this
  clone: -> new Vec2(@x, @y)
  set: (x, y) ->
    @x = x ? 0
    @y = y ? @x
  equals: (rhs) ->
    rhs.x == @x and rhs.y == @y
  copy: (rhs) -> @set(rhs.x, rhs.y)
Vec2.degToRad = Math.PI/180

module.exports = Vec2
