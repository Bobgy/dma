Vec2 = require('./Vec2.coffee')
World = require('./World.coffee')
Loader = require('./AssetsLoader.coffee')
[EventEmitter, FixedsizeEventEmitter] = require('./EventEmitter.coffee')

history = new FixedsizeEventEmitter(16)
game = new World(PIXI)
loader = new Loader(game)
loader.load()
document.body.appendChild(game.renderer.view)

socket = io()
keys = [87, 65, 83, 68, 16, 191]
karr = []
for key in keys
  karr[key] = false
id = -1

socket.on('user_id', (msg) ->
  id = msg
)
socket.on('sync', (tick, players, factions, eventEmitter) ->
  console.log('sync, server:', tick, 'client:',
              game.tick, 'delta:', tick-game.tick)
  oldTick = game.tick
  game.sync(tick, players, factions, eventEmitter)
  game.components.eventEmitter.copy(history, tick)
  if tick > oldTick or tick + 5 < oldTick
    console.log('Synchronizing...')
    for i in [1..3]
      game.update()
  else
    while game.tick < oldTick
      game.update()

)
socket.on('key', (user_id, msg, isDown, tick) ->
  console.log(user_id, 'key', msg, 'send', tick, ', rec', game.tick)
  if not (user_id == id)
    game.components.eventEmitter.pushEvent('key', tick, user_id, isDown, msg)
)
downKeyCode = (e) ->
  evt = e || window.event
  keyCode = evt.KeyCode || evt.which || evt.charCode
  switch keyCode
    when 87, 65, 83, 68, 16, 191 # w, a, s, d, shift, /
      if not karr[keyCode]
        if id < 2
          game.keyAction(id, true, keyCode)
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
        game.keyAction(id, false, keyCode)
        history.pushEvent('key', game.tick + 1, id, false, keyCode)
        socket.emit('key', keyCode, false, game.tick + 1)
      karr[keyCode] = false
document.onkeyup = upKeyCode
