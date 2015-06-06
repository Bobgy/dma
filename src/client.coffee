Vec2 = require('./Vec2.coffee')
World = require('./World.coffee')
Game = require('./Game.coffee')
Loader = require('./AssetsLoader.coffee')
[EventEmitter, FixedsizeEventEmitter] = require('./EventEmitter.coffee')

game = new Game('client', PIXI)
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

  socket.on('sync', (worldID, tick, players, enemies, eventEmitter) ->
    console.log('sync, server:', tick, 'client:',
                game.tick, 'delta:', tick-game.tick)
    world = game.worlds[worldID]
    oldTick = world.tick
    world.sync(tick, players, enemies, eventEmitter)
    world.components.eventEmitter.copy(history, tick) if world.id is id
    if tick > oldTick or tick + 5 < oldTick
      console.log('Synchronizing...')
      for i in [1..3]
        world.update(game.worlds[worldID^1])
    else
      while world.tick < oldTick
        world.update(game.worlds[worldID^1])
  )
  socket.on('key', (user_id, msg, isDown, tick) ->
    console.log(user_id, 'key', msg, 'send', tick, ', rec', game.tick)
    if not (user_id == id)
      game.worlds[user_id].components.eventEmitter.
           pushEvent('key', tick, user_id, isDown, msg)
  )
  socket.on('Servant', (tick, worldID, servant) ->
    game.worlds[worldID].components.eventEmitter.
         pushEvent('Servant', tick, tick, servant)
  )

  downKeyCode = (e) ->
    evt = e || window.event
    keyCode = evt.KeyCode || evt.which || evt.charCode
    switch keyCode
      when 87, 65, 83, 68, 16, 191 # w, a, s, d, shift, /
        if not karr[keyCode]
          if id < 2
            game.worlds[id].keyAction(0, true, keyCode)
            history.pushEvent('key', game.tick + 1, id, true, keyCode)
            socket.emit('key', keyCode, true, game.tick + 1)
          karr[keyCode] = true
  document.onkeydown = downKeyCode

  upKeyCode = (e) ->
    evt = e || window.event
    keyCode = evt.KeyCode || evt.which || evt.charCode
    switch keyCode
      when 87, 65, 83, 68, 16, 191 # w, a, s, d, shift, /
        if id < 2
          game.worlds[id].keyAction(0, false, keyCode)
          history.pushEvent('key', game.tick + 1, id, false, keyCode)
          socket.emit('key', keyCode, false, game.tick + 1)
        karr[keyCode] = false
  document.onkeyup = upKeyCode

  @game.start(15, true)
)
loader.load()
