var renderer = PIXI.autoDetectRenderer(960, 600, {backgroundColor : 0x1099bb});

document.body.appendChild(renderer.view);

// create the root of the scene graph
var stage = new PIXI.Container();

// create a texture from an image path
var texture = PIXI.Texture.fromImage('assets/bunny.png');

function animate() {
    requestAnimationFrame(animate);
    // render the container
    renderer.render(stage);
}

var socket = io();

var karr = []
var step=5, id=-1;
var players = [];

socket.on('user_id', function(msg){
	id = msg;
});
socket.on('sync', function(msg){
	stage.removeChildren();
	players = msg;
	for (var i = 0; i < players.length; ++i) {
		var player = players[i];
		var sprite = new PIXI.Sprite(texture);
		sprite.anchor.x = 0.5;
		sprite.anchor.y = 0.5;
		sprite.position.x = player.pos.x;
		sprite.position.y = player.pos.y;
		stage.addChild(sprite);
		player.sprite = sprite;
	}
});
socket.on('keyDown', function(user_id, msg){
	if (user_id == id) karr[msg] = true;
	players[user_id].keyState[msg] = true;
});
socket.on('keyUp', function(user_id, msg){
	if (user_id == id) karr[msg] = false;
	players[user_id].keyState[msg] = false;
});
function update() {
	for (var i = 0; i < players.length; ++i) {
		var player = players[i];
		if(player.keyState[87])player.pos.y-=step;
		if(player.keyState[65])player.pos.x-=step;
		if(player.keyState[83])player.pos.y+=step;
		if(player.keyState[68])player.pos.x+=step;
		player.sprite.position.x = player.pos.x;
		player.sprite.position.y = player.pos.y;
	}
}
setInterval("update()", "15");
document.onkeydown=downKeyCode;
function downKeyCode(e) {
	var evt = e || window.event;
	var keyCode = evt.KeyCode || evt.which || evt.charCode;
	switch(keyCode){
		case 87: //w
		case 65: //a
		case 83: //s
		case 68: //d
		case 16: //shift
			if(!karr[keyCode])socket.emit('keyDown', keyCode);
			break;
	}
}
document.onkeyup=upKeyCode;
function upKeyCode(e) {
	var evt = e || window.event;
	var keyCode = evt.KeyCode || evt.which || evt.charCode;
	switch(keyCode){
		case 87: //w
		case 65: //a
		case 83: //s
		case 68: //d
		case 16: //shift
			socket.emit('keyUp', keyCode);
			break;
	}
}

// start animating
animate();