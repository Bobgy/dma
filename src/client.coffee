Vec2 = require('./Vec2.coffee')
World = require('./World.coffee')
Loader = require('./AssetsLoader.coffee')
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
socket.on('sync', (players, entities, tick) ->
  console.log('sync, server:', tick, 'client:',
              game.tick, 'delta:', tick-game.tick)
  if Math.abs(tick - game.tick) > 5
    game.sync(players, entities, tick)
  else
    game.components.eventEmitter.pushEvent('sync', tick, players, entities, tick)
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
        socket.emit('key', keyCode, false, game.tick + 1)
      karr[keyCode] = false
document.onkeyup = upKeyCode
