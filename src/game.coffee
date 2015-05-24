[World, Player] = require('./core.js')
game = new World(PIXI)

document.body.appendChild(game.renderer.view)

socket = io()

karr = []
id = -1

socket.on('user_id', (msg) ->
	id = msg
)
socket.on('sync', (players, entities) ->
	game.sync(players, entities)
)
socket.on('keyDown', (user_id, msg) ->
	if user_id is not id
		game.keyAction(user_id, true, msg)
)
socket.on('keyUp', (user_id, msg) ->
	if user_id is not id
		game.keyAction(user_id, false, msg)
)

downKeyCode = (e) ->
	evt = e || window.event
	keyCode = evt.KeyCode || evt.which || evt.charCode
	switch keyCode
		when 87, 65, 83, 68, 16, 191 # w, a, s, d, shift, /
			if not karr[keyCode]
				socket.emit('keyDown', keyCode)
				if id < 2 then game.keyAction(id, true, keyCode)
			karr[keyCode] = true
document.onkeydown = downKeyCode

upKeyCode = (e) ->
	evt = e || window.event
	keyCode = evt.KeyCode || evt.which || evt.charCode
	switch keyCode
		when 87, 65, 83, 68, 16, 191 # w, a, s, d, shift, /
			socket.emit('keyUp', keyCode)
			if id < 2 then game.keyAction(id, false, keyCode)
			karr[keyCode] = false
document.onkeyup = upKeyCode

# start animating
game.run(7)