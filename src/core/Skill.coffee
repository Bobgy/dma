Container = require('./Container')
util = require('./util')

# Skill is a base component class used to describe a player's skill.
# A skill has a cooldown which is the required time before reusing the skill.
# It also has a manacost which is the amount of mana used.
# When the skill is cast, `cast(world, parent)` will be called.
# Inherit from this class and overide cast to add your own skill
class Skill extends Container
  # @param args:
  #   coolDown {int}
  #   manaCost {int}
  #   initTime {int}: time required before initially ready
  #
  # @param id {string}
  # @param coolDown {int}
  # @param manaCost {int}
  # @param currentTick {int}
  constructor: (args, id) ->
    super(args, id)
    @currentTick = @args.initTime
    @copyable = true

  update: (world, parent) ->
    super(world, parent)
    @currentTick-- if @currentTick
    if @currentTick is 0 and
        parent.mana >= @args.manaCost and
        parent.keyState[191] #key: '/', TODO: keymapping
      @currentTick = @args.coolDown
      parent.mana -= @args.manaCost
      @cast(world, parent)
    return this

  preset: ->
    super()
    args =
      coolDown: 120
      manaCost: 300
      initTime: 120
    util.setArgs(@args, args)

  cast: (world, parent) ->
    # do nothing, overide this function to add a new skill
    return this

  clone: -> (new Skill(@args, @id)).copy(this)

  copy: (rhs) ->
    super(rhs)
    @currentTick = rhs.currentTick
    return this

module.exports = Skill
