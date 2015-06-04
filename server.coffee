path = require('path')
express = require('express')
app = express()
http = require('http').Server(app)
io = require('socket.io')(http)

Vec2 = require('./src/Vec2.coffee')
Player = require('./src/Player.coffee')
Bullet = require('./src/Bullet.coffee')
World = require('./src/World.coffee')
game = new World()

# set routes
app.use('/', express.static(path.join(__dirname, 'public')))
app.use(express.static(path.join(__dirname, 'js')))
app.use('/assets', express.static(path.join(__dirname, 'assets')))

sockets = []
keys = [16, 65, 68, 83, 87, 191]

game.run(15)

synchronize = () ->
  io.emit('sync', game.tick, game.players,
          game.factions, game.components.eventEmitter)

setInterval(synchronize, 2000)

user_count = 0
io.on('connection', (socket) ->
  user_id = user_count++
  user = 'user_' + user_id
  socket.emit('user_id', user_id)
  sockets.push(socket)
  if user_id < 2
    pos = new Vec2(300, if user_id then 500 else 100)
    face = new Vec2(0, if user_id then -1 else 1)
    player = new Player(user_id, pos, new Vec2(), face)
    game.addPlayer(player)
    socket.on('key', (keyCode, isDown, tick) ->
      socket.broadcast.emit('key', user_id, keyCode, isDown, tick)
      if tick <= game.tick
        console.log(user, 'key', keyCode, 'send', tick, ', rec', game.tick)
      game.components.eventEmitter.pushEvent(
          'key', tick, user_id,
          isDown, keyCode
      )
    )
  socket.broadcast.emit('sync', game.players, game.entities)
  if user_id==1 then sockets[0].emit('sync', game.players)
  console.log(user + ' connected')
  socket.on('disconnect', ->
    console.log(user + ' disconnected')
  )
)

http.listen(3000, () ->
  console.log('listening on *:3000')
)
