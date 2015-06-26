var path = require('path');
var express = require('express');
var app = express();
var http = require('http').Server(app);
var io = require('socket.io')(http);
var Server = require('./js/server');
var server = new Server(io);

app.use('/', express.static(path.join(__dirname, 'public')));
app.use(express.static(path.join(__dirname, 'js')));
app.use('/assets', express.static(path.join(__dirname, 'assets')));

http.listen(3000, function() {
  console.log('listening on *:3000')
});

server.listen();
