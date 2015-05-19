var path = require('path');

var express = require('express');
var app = express();
var http = require('http').Server(app);
var io = require('socket.io')(http);

//set routes
app.use('/', express.static(path.join(__dirname, 'public')));
app.use(express.static(path.join(__dirname, 'js')));
app.use('/assets', express.static(path.join(__dirname, 'assets')));

var user_count = 0;
var players = [];
var sockets = [];
var keys = [87, 65, 83, 68]

var step = 5;
var update=function(){
	for (var i = 0; i < players.length; ++i) {
		var player = players[i];
		if(player.keyState[87])player.pos.y-=step;
		if(player.keyState[65])player.pos.x-=step;
		if(player.keyState[83])player.pos.y+=step;
		if(player.keyState[68])player.pos.x+=step;
		//console.log(player.pos);
	}
}
setInterval(update, 15);

var synchronize=function(){
	io.emit('sync', players);
}
setInterval(synchronize, 120);

io.on('connection', function(socket){
	var user_id = user_count++;
	var user = 'user ' + user_id;
	socket.emit('user_id', user_id);
	sockets.push(socket);
	if (user_id<2) {
		var player = {};
		player.pos = {'x': 300, 'y': user_id ? 500 : 100};
		player.keyState = {};
		players.push(player);
		socket.on('keyDown', function(msg){
			io.emit('keyDown', user_id, msg);
			console.log(user + ' keyDown: ' + msg);
			players[user_id].keyState[msg] = true;
		});
		socket.on('keyUp', function(msg){
			io.emit('keyUp', user_id, msg);
			console.log(user + ' keyUp: ' + msg);
			players[user_id].keyState[msg] = false;
		});
	}
	socket.emit('sync', players);
	if (user_id==1) {
		sockets[0].emit('sync', players);
	}
	console.log(user + ' connected');
	socket.on('disconnect', function(){
		console.log(user + ' disconnected');
	});
});

http.listen(3000, function(){
	console.log('listening on *:3000');
});