[World, Player, Bullet] = require('./core.coffee')
Vec2 = require('./Vec2.coffee')
game = new World(PIXI)

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
socket.on('sync', (players, entities) ->
	game.sync(players, entities)
)
socket.on('keyDown', (user_id, msg) ->
	console.log(user_id + ' keyDown ' + msg)
	if not (user_id == id)
		game.keyAction(user_id, true, msg)
)
socket.on('keyUp', (user_id, msg) ->
	console.log(user_id + ' keyUp ' + msg)
	if not (user_id == id)
		game.keyAction(user_id, false, msg)
)
downKeyCode = (e) ->
	evt = e || window.event
	keyCode = evt.KeyCode || evt.which || evt.charCode
	switch keyCode
		when 87, 65, 83, 68, 16, 191 # w, a, s, d, shift, /
			if not karr[keyCode]
				if id < 2 then game.keyAction(id, true, keyCode)
				karr[keyCode] = true
				socket.emit('keyDown', keyCode)
document.onkeydown = downKeyCode

upKeyCode = (e) ->
	evt = e || window.event
	keyCode = evt.KeyCode || evt.which || evt.charCode
	switch keyCode
		when 87, 65, 83, 68, 16, 191 # w, a, s, d, shift, /
			if id < 2 then game.keyAction(id, false, keyCode)
			karr[keyCode] = false
			socket.emit('keyUp', keyCode)
document.onkeyup = upKeyCode

# start animating
game.run(7)