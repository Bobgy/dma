display = true

require('./core.js')(true)

renderer = PIXI.autoDetectRenderer(960, 600, {backgroundColor : 0x1099bb})

document.body.appendChild(renderer.view)

# create the root of the scene graph
stage = new PIXI.Container()

# create a texture from an image path
texture = PIXI.Texture.fromImage('assets/bunny.png')

animate = ->
    requestAnimationFrame(animate)
    # render the container
    renderer.render(stage)

socket = io()

karr = []
step = 5
id = -1
players = []

socket.on('user_id', (msg) ->
	id = msg
)
socket.on('sync', (msg) ->
	stage.removeChildren()
	players = msg
	for player in players
		sprite = new PIXI.Sprite(texture)
		sprite.anchor.x = 0.5
		sprite.anchor.y = 0.5
		sprite.position.x = player.pos.x
		sprite.position.y = player.pos.y
		stage.addChild(sprite)
		player.sprite = sprite
)
socket.on('keyDown', (user_id, msg) ->
	if (user_id == id) then karr[msg] = true
	players[user_id].keyState[msg] = true
)
socket.on('keyUp', (user_id, msg) ->
	if (user_id == id) then karr[msg] = false
	players[user_id].keyState[msg] = false
)
update = ->
	for player in players
		if player.keyState[87] then player.pos.y-=step
		if player.keyState[65] then player.pos.x-=step
		if player.keyState[83] then player.pos.y+=step
		if player.keyState[68] then player.pos.x+=step
		player.sprite.position.x = player.pos.x
		player.sprite.position.y = player.pos.y

setInterval(update, 15)
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
animate()