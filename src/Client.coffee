Core = require('./lib/index')
for id, mod of Core
  eval("#{id}=Core.#{id}")
Loader = require('./AssetsLoader.coffee')
Game = require('./Game.coffee')

game = new Game(null, 'client', PIXI)
id = -1
socket = io()
socket.on('userID', (msg) -> id = parseInt(msg) )

loader = new Loader(game, ->
  console.log('Assets are loaded.')
  @game.assets = @loader.resources

  history = new FixedsizeEventEmitter(16)
  document.body.appendChild(game.renderer.view)

  keys = [87, 65, 83, 68, 16, 191]
  keyMovement = keys.slice(0, 5)

  karr = []
  for key in keys
    karr[key] = false

  verbose = false
  socket.on('sync', (worldID, tick, players, enemies, eventEmitter, pools) ->
    world = game.worlds[worldID]
    oldTick = world.tick

    # Verbose
    if verbose and world.id is id
      oldPos = world.players[0].pos.clone() if world.players[0]?
    # End

    world.sync(tick, players, enemies, eventEmitter, pools)
    if world.id is id
      delta = oldTick - tick
      unless 1 < delta < 10
        console.log('sync, server:', tick, 'client:',
                    oldTick, 'delta:', oldTick-tick)
      world.components.eventEmitter.copy(history, tick)
      if tick+1 < oldTick < tick+10
        while world.tick < oldTick
          world.earlyUpdate(game.worlds[worldID^1])
          world.update(game.worlds[worldID^1])
      else
        console.log('Synchronizing...')
        for i in [1..8]
          world.earlyUpdate(game.worlds[worldID^1])
          world.update(game.worlds[worldID^1])

      # Verbose
      if oldPos?
        newPos = world.players[0].pos.clone()
        console.log(newPos.sub(oldPos))
      # End
  )
  socket.on('key', (user_id, msg, isDown, tick) ->
    console.log(user_id, 'key', msg, 'send', tick, ', rec',
                game.worlds[user_id].tick)
    game.worlds[user_id].components.eventEmitter.
         pushEvent('key', tick, 0, isDown, msg)
  )
  socket.on('Servant', (tick, worldID, servant) ->
    game.worlds[worldID].components.eventEmitter.
         pushEvent('Servant', tick, tick, servant)
  )

  onKey = (isDown, e) ->
    evt = e || window.event
    keyCode = evt.KeyCode || evt.which || evt.charCode
    switch keyCode
      when 87, 65, 83, 68, 16, 191 # w, a, s, d, shift, /
        if id < 2
          world = game.worlds[id]
          if world.keyAction(0, isDown, keyCode)
            history.pushEvent('key', world.tick + 1, 0, isDown, keyCode)
            socket.emit('key', keyCode, isDown, world.tick + 1)
  document.onkeydown = onKey.bind(null, true)
  document.onkeyup = onKey.bind(null, false)

  @game.start(15, false)
)
loader.load()
