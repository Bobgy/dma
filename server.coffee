path = require('path')

express = require('express')
app = express()
http = require('http').Server(app)
io = require('socket.io')(http)
core = require('./js/core.js')


# set routes
app.use('/', express.static(path.join(__dirname, 'public')))
app.use(express.static(path.join(__dirname, 'js')))
app.use('/assets', express.static(path.join(__dirname, 'assets')))

user_count = 0
players = []
sockets = []
keys = [87, 65, 83, 68, 16]

short_step = 1.5
long_step = 3
update = () ->
	for player in players
		step = if player.keyState[16] then short_step else long_step
		player.pos.y -= step if player.keyState[87]
		player.pos.x -= step if player.keyState[65]
		player.pos.y += step if player.keyState[83]
		player.pos.x += step if player.keyState[68]

setInterval(update, 7)

synchronize = () -> io.emit('sync', players)

setInterval(synchronize, 14)

io.on('connection', (socket) ->
	user_id = user_count++
	user = 'user ' + user_id
	socket.emit('user_id', user_id)
	sockets.push(socket)
	if user_id < 2
		player = {}
		player.pos = {'x': 300, 'y': if user_id then 500 else 100}
		player.keyState = {}
		players.push(player)
		socket.on('keyDown', (msg) ->
			io.emit('keyDown', user_id, msg)
			console.log(user + ' keyDown: ' + msg)
			players[user_id].keyState[msg] = true
		)
		socket.on('keyUp', (msg) ->
			io.emit('keyUp', user_id, msg)
			console.log(user + ' keyUp: ' + msg)
			players[user_id].keyState[msg] = false
		)
	socket.emit('sync', players)
	if user_id==1 then sockets[0].emit('sync', players)
	console.log(user + ' connected')
	socket.on('disconnect', ->
		console.log(user + ' disconnected')
	)
)

http.listen(3000, () ->
	console.log('listening on *:3000')
)