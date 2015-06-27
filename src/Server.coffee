core = require('./core')
Game = require('./Game')
util = core.util
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
    for user, id in @users
      socket = @sockets[user]
      if socket?
        socket.emit('id', id)
    synchronize = () =>
      for user, id in @users
        socket = @sockets[user]
        if socket?
          socket.emit('id', id)
          socket.emit('score', @game.score)
          for world in @game.worlds
            socket.emit('sync', world.id, world.tick, world.players,
                  world.get('enemies'), world.get('eventEmitter'),
                  world.get('pools'))
    @syncProcess = setInterval(synchronize, 2000)
    syncPlayer = =>
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
    @sockets = Object.create(null)
    @games = Object.create(null)
    @waitList = Object.create(null)

  listen: ->
    sockets = @sockets
    games = @games
    waitList = @waitList
    socketCount = 0
    @io.on('connection', (socket) ->
      state = 0 # waiting for user_id
      userID = null
      socketID = socketCount++
      socket.on('user_id', (user_id) ->
        if state == 0
          userID = user_id
          sockets[user_id] = socket
          console.log("#{socketID} connected with #{userID}")
          #                        reconnect   login
          if games[userID]?
            console.log("#{userID} reconnected")
          state = 1
        return
      )
      socket.on('disconnect', ->
        if state > 0
          delete sockets[userID]
          delete waitList[userID]
          console.log("#{socketID} disconnected with #{userID}")
        else
          console.log("#{socketID} disconnected")
        return
      )
      socket.on('match', ->
        if state == 0
          console.warn('Attempt to match when not logged in.')
        else
          if Object.hasOwnProperty.call(waitList, userID) then return
          for user of waitList
            opponentID = user
            gameServer = new GameServer([opponentID, userID], sockets, ->
              gameServer.destroy()
              delete games[opponentID]
              delete games[userID]
            )
            games[opponentID] = gameServer
            games[userID] = gameServer
            gameServer.start()
            console.log("#{userID} and #{opponentID} started a game")
            return
          waitList[userID] = 1 # waiting
          console.log("#{userID} is waiting")
        return
      )

      socket.on('key', (keyCode, isDown, tick) ->
        if state > 0
          gameServer = games[userID]
          if not gameServer? then throw new Error('state == 2, but not in game')
          idx = gameServer.index(userID)
          console.log("[#{tick}] player #{idx} #{keyCode} #{isDown} received")
          if keyCode in movementKeys
            sockets[gameServer.other(userID)].emit(
              'key', idx, keyCode, isDown, tick
            )
          game = gameServer.game
          world = game.worlds[idx]
          if tick <= world.tick
            console.warn('Warning:', userID, 'key', keyCode,
                        'send', tick, ', rec', world.tick)
          world.get('eventEmitter').pushEvent(
            'key', tick, 0, isDown, keyCode
          )
        return
      )

      console.log("#{socketID} connected")
    )
    return

module.exports = Server
