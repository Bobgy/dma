[World, Player] = require('./core.js')
game = new World(PIXI)

document.body.appendChild(game.renderer.view)

socket = io()

karr = []
id = -1

socket.on('user_id', (msg) ->
	id = msg
)
socket.on('sync', (msg) ->
	players = msg
	game.sync(players)
)
socket.on('keyDown', (user_id, msg) ->
	if (user_id == id) then karr[msg] = true
	game.keyAction(user_id, true, msg)
)
socket.on('keyUp', (user_id, msg) ->
	if (user_id == id) then karr[msg] = false
	game.keyAction(user_id, false, msg)
)

downKeyCode = (e) ->
	evt = e || window.event
	keyCode = evt.KeyCode || evt.which || evt.charCode
	switch keyCode
		when 87, 65, 83, 68, 16 # w, a, s, d, shift
			if not karr[keyCode]
				socket.emit('keyDown', keyCode)
document.onkeydown = downKeyCode

upKeyCode = (e) ->
	evt = e || window.event
	keyCode = evt.KeyCode || evt.which || evt.charCode
	switch keyCode
		when 87, 65, 83, 68, 16 # w, a, s, d, shift
			socket.emit('keyUp', keyCode)
document.onkeyup = upKeyCode

# start animating
game.run(7)