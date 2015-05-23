(function() {
  var app, express, http, io, keys, long_step, path, players, short_step, sockets, synchronize, update, user_count;

  path = require('path');

  express = require('express');

  app = express();

  http = require('http').Server(app);

  io = require('socket.io')(http);

  app.use('/', express["static"](path.join(__dirname, 'public')));

  app.use(express["static"](path.join(__dirname, 'js')));

  app.use('/assets', express["static"](path.join(__dirname, 'assets')));

  user_count = 0;

  players = [];

  sockets = [];

  keys = [87, 65, 83, 68, 16];

  short_step = 1.5;

  long_step = 3;

  update = function() {
    var i, len, player, results, step;
    results = [];
    for (i = 0, len = players.length; i < len; i++) {
      player = players[i];
      step = player.keyState[16] ? short_step : long_step;
      if (player.keyState[87]) {
        player.pos.y -= step;
      }
      if (player.keyState[65]) {
        player.pos.x -= step;
      }
      if (player.keyState[83]) {
        player.pos.y += step;
      }
      if (player.keyState[68]) {
        results.push(player.pos.x += step);
      } else {
        results.push(void 0);
      }
    }
    return results;
  };

  setInterval(update, 7);

  synchronize = function() {
    return io.emit('sync', players);
  };

  setInterval(synchronize, 14);

  io.on('connection', function(socket) {
    var player, user, user_id;
    user_id = user_count++;
    user = 'user ' + user_id;
    socket.emit('user_id', user_id);
    sockets.push(socket);
    if (user_id < 2) {
      player = {};
      player.pos = {
        'x': 300,
        'y': user_id ? 500 : 100
      };
      player.keyState = {};
      players.push(player);
      socket.on('keyDown', function(msg) {
        io.emit('keyDown', user_id, msg);
        console.log(user + ' keyDown: ' + msg);
        return players[user_id].keyState[msg] = true;
      });
      socket.on('keyUp', function(msg) {
        io.emit('keyUp', user_id, msg);
        console.log(user + ' keyUp: ' + msg);
        return players[user_id].keyState[msg] = false;
      });
    }
    socket.emit('sync', players);
    if (user_id === 1) {
      sockets[0].emit('sync', players);
    }
    console.log(user + ' connected');
    return socket.on('disconnect', function() {
      return console.log(user + ' disconnected');
    });
  });

  http.listen(3000, function() {
    return console.log('listening on *:3000');
  });

}).call(this);

//# sourceMappingURL=server.js.map
