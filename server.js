var app = require('express')();
var http = require('http').Server(app);
var io = require('socket.io')(http);

app.get('/', function(req, res) {
  res.sendFile(__dirname+'/public/index.html')
});

io.on('connection', function(socket){
	console.log('a user connected');
	socket.on('disconnect', function(){
		console.log('user disconnected');
	});
	socket.on('key', function(msg){
		io.emit('key', { for: 'everyone', data: msg });
		console.log('keyDown: ' + msg);
	});
	socket.on('keyUp', function(msg){
		io.emit('keyUp', { for: 'everyone', data: msg });
		console.log('keyUp: ' + msg);
	});
});

http.listen(3000, function(){
	console.log('listening on *:3000');
});