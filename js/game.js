(function() {
  var animate, downKeyCode, id, karr, players, renderer, socket, stage, step, texture, upKeyCode, update;

  renderer = PIXI.autoDetectRenderer(960, 600, {
    backgroundColor: 0x1099bb
  });

  document.body.appendChild(renderer.view);

  stage = new PIXI.Container();

  texture = PIXI.Texture.fromImage('assets/bunny.png');

  animate = function() {
    requestAnimationFrame(animate);
    return renderer.render(stage);
  };

  socket = io();

  karr = [];

  step = 5;

  id = -1;

  players = [];

  socket.on('user_id', function(msg) {
    return id = msg;
  });

  socket.on('sync', function(msg) {
    var i, len, player, results, sprite;
    stage.removeChildren();
    players = msg;
    results = [];
    for (i = 0, len = players.length; i < len; i++) {
      player = players[i];
      sprite = new PIXI.Sprite(texture);
      sprite.anchor.x = 0.5;
      sprite.anchor.y = 0.5;
      sprite.position.x = player.pos.x;
      sprite.position.y = player.pos.y;
      stage.addChild(sprite);
      results.push(player.sprite = sprite);
    }
    return results;
  });

  socket.on('keyDown', function(user_id, msg) {
    if (user_id === id) {
      karr[msg] = true;
    }
    return players[user_id].keyState[msg] = true;
  });

  socket.on('keyUp', function(user_id, msg) {
    if (user_id === id) {
      karr[msg] = false;
    }
    return players[user_id].keyState[msg] = false;
  });

  update = function() {
    var i, len, player, results;
    results = [];
    for (i = 0, len = players.length; i < len; i++) {
      player = players[i];
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
        player.pos.x += step;
      }
      player.sprite.position.x = player.pos.x;
      results.push(player.sprite.position.y = player.pos.y);
    }
    return results;
  };

  setInterval(update, 15);

  downKeyCode = function(e) {
    var evt, keyCode;
    evt = e || window.event;
    keyCode = evt.KeyCode || evt.which || evt.charCode;
    switch (keyCode) {
      case 87:
      case 65:
      case 83:
      case 68:
      case 16:
        if (!karr[keyCode]) {
          return socket.emit('keyDown', keyCode);
        }
    }
  };

  document.onkeydown = downKeyCode;

  upKeyCode = function(e) {
    var evt, keyCode;
    evt = e || window.event;
    keyCode = evt.KeyCode || evt.which || evt.charCode;
    switch (keyCode) {
      case 87:
      case 65:
      case 83:
      case 68:
      case 16:
        return socket.emit('keyUp', keyCode);
    }
  };

  document.onkeyup = upKeyCode;

  animate();

}).call(this);

//# sourceMappingURL=game.js.map
