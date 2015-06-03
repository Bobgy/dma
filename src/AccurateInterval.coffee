class AccurateInterval
  constructor: (@fn, @interval) ->
    @valid = true
    @next = Date.now() + @interval
    setTimeout(@gao, @interval)

  gao: =>
    if @valid
      @next += @interval
      setTimeout(@gao, @next - Date.now())
      @fn()

  reset: -> @next = Date.now()

  off: -> @valid = false

module.exports = AccurateInterval
