class AccurateInterval
  constructor: (@fn, @interval) ->
    @valid = true
    @next = Date.now() + @interval
    setTimeout(@gao, @interval)

  gao: =>
    if @valid
      @next += @interval
      if @next - Date.now() < -60
        console.log('Error: Framerate is too low, reset!')
        @reset()
      setTimeout(@gao, @next - Date.now())
      @fn()

  reset: -> @next = Date.now() + @interval

  off: -> @valid = false

module.exports = AccurateInterval
