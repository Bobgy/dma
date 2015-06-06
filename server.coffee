path = require('path')
express = require('express')
app = express()
http = require('http').Server(app)
io = require('socket.io')(http)

Vec2 = require('./src/Vec2.coffee')
Player = require('./src/Player.coffee')
Bullet = require('./src/Bullet.coffee')
World = require('./src/World.coffee')
Game = require('./src/Game.coffee')
SkillSummonServant = require('./src/scripts/skills/SummonServant.coffee')
game = new Game('server')
game.io = io

# set routes
app.use('/', express.static(path.join(__dirname, 'public')))
app.use(express.static(path.join(__dirname, 'js')))
app.use('/assets', express.static(path.join(__dirname, 'assets')))

sockets = []
keys = [16, 65, 68, 83, 87, 191]
movementKeys = keys.slice(0, 5)

game.start(15, false)
synchronize = () ->
  for world in game.worlds
    io.emit('sync', world.id, world.tick, world.players,
            world.components.enemies, world.components.eventEmitter)
    console.log('world',world.id,', tick',world.tick)

setInterval(synchronize, 2000)

user_count = 0
io.on('connection', (socket) ->
  userID = user_count++
  user = 'user_' + userID
  socket.emit('userID', userID)
  sockets.push(socket)
  if userID < 2
    pos = new Vec2(300, if userID then 500 else 100)
    face = new Vec2(0, if userID then -1 else 1)
    player = new Player(userID, pos, new Vec2(), face)
    player.components.skill = new SkillSummonServant('skill')
    game.worlds[userID].addPlayer(player)
    socket.on('key', (keyCode, isDown, tick) ->
      if keyCode in movementKeys
        socket.broadcast.emit('key', userID, keyCode, isDown, tick)
      if tick <= game.tick
        console.log(user, 'key', keyCode, 'send', tick, ', rec', game.tick)
      game.worlds[userID].components.eventEmitter.pushEvent(
          'key', tick, 0,
          isDown, keyCode
      )
    )
  for world in game.worlds
    socket.broadcast.emit('sync', world.id, world.tick, world.players,
              world.components.enemies, world.components.eventEmitter)
  if userID==1
    sockets[0].emit('sync', world.id, world.tick, world.players,
                   world.components.enemies, world.components.eventEmitter)
  console.log(user + ' connected')
  socket.on('disconnect', ->
    console.log(user + ' disconnected')
  )
)

http.listen(3000, () ->
  console.log('listening on *:3000')
)
