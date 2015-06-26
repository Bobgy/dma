Core = require('./lib')
Game = require('./Game')
util = Core.util
Vec2 = util.Vec2
keys = [16, 65, 68, 83, 87, 191]
movementKeys = keys.slice(0, 5)

class GameServer
  # @param sockets {Array[2] of socket}
  constructor: (@users, @sockets, @fn) ->
    @game = new Game(null, 'server')
    @game.users = @users
    @game.sockets = @sockets
    @game.initPlayers()
    @syncProcess = null

  index: (id) ->
    return switch id
      when @users[0] then 0
      when @users[1] then 1
      else throw new Error('id not found')
  other: (id) ->
    return @users[@index(id) ^ 1]

  start: (interval=15) ->
    synchronize = () ->
      io.emit('score', @game.score)
      for world in @game.worlds
        for user in @users
          socket = @sockets[user]
          if socket?
            socket.emit('sync', world.id, world.tick, world.players,
                  world.get('enemies'), world.get('eventEmitter'),
                  world.get('pools'))
    @syncProcess = setInterval(synchronize, 2000)
    syncPlayer = ->
      for world in game.worlds
        id = world.id
        if sockets[id^1]?
          sockets[id^1].emit('syncPlayer', world.id, world.tick, world.players)
    # setInterval(syncPlayer, 100)
    @game.start(interval)

  destroy: ->
    @game.process.off()
    @game = null
    @syncProcess.clearInterval()
    @syncProcess = null

class Server
  constructor: (@io) ->
    @sockets = new Object
    @games = new Object
    @waitList = []

  listen: ->
    sockets = @sockets
    games = @games
    waitList = @waitList
    io.on('connection', (socket) ->
      state = 0 # waiting for user_id
      userID = null
      socket.on('user_id', (user_id) ->
        if state == 0
          userID = user_id
          sockets[user_id] = socket
          console.log("#{userID} connected")
          #                        reconnect   login
          state = if games[userID]? then 2 else 1
        return
      )
      socket.on('disconnect', ->
        if state > 0
          delete sockets[userID]
          console.log(userID + ' disconnected')
        return
      )
      socket.on('match', ->
        if state == 0
          console.warn('Attempt to match when not logged in.')
        else
          i = 0
          for user in waitList
            if sockets[user]?
              waitList[i] = user
              i++
          if i < waitList.length
            waitList.splice(i + 1, waitList.length - i)
          if waitList.length > 0
            opponentID = waitList.pop()
            gameServer = new GameServer([opponentID, userID], sockets, ->
              gameServer.destroy()
              delete games[opponentID]
              delete games[userID]
              state = 1
            )
            state = 2 # in game
            games[opponentID] = gameServer
            games[userID] = gameServer
            gameServer.start()
          else
            waitList.push(userID) # waiting
        return
      )

      socket.on('key', (keyCode, isDown, tick) ->
        if state == 2 # in game
          gameServer = games[userID]
          if not gameServer? then throw new Error('state == 2, but not in game')
          if keyCode in movementKeys
            sockets[gameServer.other(userID)].emit(
              'key', userID, keyCode, isDown, tick
            )
          world = gameServer.game.worlds[game.index(userID)]
          if tick <= world.tick
            console.warn('Warning:', userID, 'key', keyCode,
                        'send', tick, ', rec', world.tick)
          world.get('eventEmitter').pushEvent(
            'key', tick, 0, isDown, keyCode
          )
        return
      )

      console.log('Someone connected')
    )

module.exports = Server
