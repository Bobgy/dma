"use strict"

Core = require('./lib/index')
for id, mod of Core
  this[id] = mod
Loader = require('./AssetsLoader')
Game = require('./Game')

game = new Game(null, 'client', PIXI)
id = -1
socket = io()
socket.on('userID', (msg) -> id = parseInt(msg) )

loader = new Loader(game, ->
  console.log('Assets are loaded.')
  @game.assets = @loader.resources

  history = new Core.EventEmitter.FixedsizeEventEmitter(16)
  document.body.appendChild(game.renderer.view)

  keys = [87, 65, 83, 68, 16, 191]
  keyMovement = keys.slice(0, 5)

  karr = []
  for key in keys
    karr[key] = false

  verbose = false
  socket.on('syncPlayer', (worldID, tick, players) ->
    world = game.worlds[worldID]
    world.get('eventEmitter')
      .pushEvent('syncPlayer', tick, players)
  )

  socket.on('sync', (worldID, tick, players, enemies, eventEmitter, pools) ->
    console.log("[#{tick}] sync #{worldID}")
    world = game.worlds[worldID]
    oldTick = world.tick

    # Verbose
    if world.id is id
      oldPos = world.players[0].pos.clone() if world.players[0]?
    # End

    world.sync(tick, players, enemies, eventEmitter, pools)

    world.components.eventEmitter.copy(history, tick) if world.id is id
    if tick+1 < oldTick < tick+10
      while world.tick < oldTick
        world.earlyUpdate(game.worlds[worldID^1])
        world.update(game.worlds[worldID^1])
    else
      console.warn('Sync, server:', tick, 'client:',
                  oldTick, 'delta:', oldTick-tick)
      for i in [1..8]
        world.earlyUpdate(game.worlds[worldID^1])
        world.update(game.worlds[worldID^1])

    # Verbose
    if oldPos?
      newPos = world.players[0].pos.clone()
      unless newPos.x == oldPos.x and newPos.y == oldPos.y
        console.warn('Delta:', newPos.sub(oldPos))
    # End
  )

  socket.on('key', (user_id, msg, isDown, tick) ->
    console.log(user_id, 'key', msg, 'send', tick, ', rec',
                game.worlds[user_id].tick)
    game.worlds[user_id].components.eventEmitter.
         pushEvent('key', tick, 0, isDown, msg)
  )

  socket.on('score', (score) ->
    game.score = score
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
            console.log("[#{world.tick+1}] #{keyCode} #{isDown}");
  document.onkeydown = onKey.bind(null, true)
  document.onkeyup = onKey.bind(null, false)

  @game.start(15, false)
)
loader.load()
