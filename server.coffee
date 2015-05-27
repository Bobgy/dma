path = require('path')

express = require('express')
app = express()
http = require('http').Server(app)
io = require('socket.io')(http)
[World, Player, Vec2, Bullet] = require('./src/core.coffee')
game = new World()

# set routes
app.use('/', express.static(path.join(__dirname, 'public')))
app.use(express.static(path.join(__dirname, 'js')))
app.use('/assets', express.static(path.join(__dirname, 'assets')))

sockets = []
keys = [16, 65, 68, 83, 87, 191]

game.run(7)

center = new Vec2(game.w/2, game.h/2)
game.addEntity(new Bullet(10, center, new Vec2(0.1, -0.2)))
game.addEntity(new Bullet(10, center, new Vec2(0, 0)))

synchronize = () -> io.emit('sync', game.players, game.entities)
setInterval(synchronize, 14)

a = {}
b = {}
b.c = 'abc'
a.b = b
user_count = 0
io.on('connection', (socket) ->
	socket.emit('test', a, b);
	user_id = user_count++
	user = 'user ' + user_id
	socket.emit('user_id', user_id)
	sockets.push(socket)
	if user_id < 2
		player = new Player(user_id, new Vec2(300, if user_id then 500 else 100))
		game.addPlayer(player)
		socket.on('keyDown', (msg) ->
			io.emit('keyDown', user_id, msg)
			console.log(user + ' keyDown: ' + msg)
			game.keyAction(user_id, true, msg)
		)
		socket.on('keyUp', (msg) ->
			io.emit('keyUp', user_id, msg)
			console.log(user + ' keyUp: ' + msg)
			game.keyAction(user_id, false, msg)
		)
	socket.emit('sync', game.players, game.entities)
	if user_id==1 then sockets[0].emit('sync', game.players)
	console.log(user + ' connected')
	socket.on('disconnect', ->
		console.log(user + ' disconnected')
	)
)

http.listen(3000, () ->
	console.log('listening on *:3000')
)