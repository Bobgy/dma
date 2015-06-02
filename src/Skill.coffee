# Skill is a base component class used to describe a player's skill.
# A skill has a cooldown which is the required time before reusing the skill.
# It also has a manacost which is the amount of mana used.
# When the skill is cast, `cast(world, parent)` will be called.
# Inherit from this class and overide cast to add your own skill
class Skill
  # @param name {string}
  # @param coolDown {int}
  # @param manaCost {int}
  # @param currentTick {int}
  constructor: (@name='', @coolDown=120, @manaCost=240, @currentTick=0) ->
  update: (world, parent) ->
    @currentTick-- if @currentTick
    if @currentTick is 0 and
        parent.mana >= @manaCost and
        parent.keyState[191] #key: '/'
      @currentTick = @coolDown
      parent.mana -= @manaCost
      @cast(world, parent)
    return this

  cast: (world, parent) ->
    # do nothing, overide this function to add a new skill
    return this

  clone: ->
    skill = new Skill(@name, @coolDown, @manaCost, @currentTick)
    return this

  copy: (rhs) ->
    @name = rhs.name
    @coolDown = rhs.coolDown
    @manaCost = rhs.manaCost
    @currentTick = rhs.currentTick
    return this

module.exports = Skill
