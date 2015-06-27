# DanMaku Arena

This is my project for b/s programming course. It is a multiplayer game which belongs to the STG (Shoot 'Em Up Games) genre.

Two players each occupy half of the screen. They summon servants to attack each other rather than directly shooting bullets. This make the gameplay more like The Touhou Project a.k.a. Project Shrine Maiden.

Similarly, player controlled characters have a small collision box. And they can focus to reduce the moving speed facilitating dodging bullets.

The game is run in a browser/server architecture. The server side uses Node.js. Most modern browsers should be supported as browser side. Delay should be mostly dealt with by the game's design and synchronization strategies. I am expecting reasonable gameplay experience with delay less than 100 ms.

This repository contains the game server with a minimal web server that only serves the game. Another [repository of mine](https://github.com/Bobgy/dma_web) contains a web server that enables additional user registration and etc.

## How to play
- visit the game's webpage, e.g. http://localhost:3000
- controls
  - **W/A/S/D** hold to move up / left / down / right
  - **Shift** hold to slow down
  - **"/"** press to summon a servant ( There's a hidden mana bar, you can only summon a new servant when you have enough mana. Mana recovers by time. )

## How to deploy server

Install the module into "node_modules/danmaku.arena"
```
$> npm install danmaku.arena
```
Start a server on port 3000
```
$> cd node_modules/danmaku.arena
$> npm start
```
## How to build

Besides a node installation, you need coffee-script and grunt to build this project.
```
$> npm install -g coffee-script
$> npm install -g grunt-cli
```

Install dependencies
```
$> npm install
```
Build the project
```
$> grunt
```
Visit "http://localhost:3000" to play the game, a game requires two players.

**Note** socket.io, which I depended on, cannot be easily installed on Windows 7/8 currently. Here's the quick fix.

```bash
$> cd node_modules/socket.io/node_modules/engine.io/node_modules/ws
# Change the release of nan to 1.6.0
$> vim package.json
# I used Visual Studio 2013
$> node-gyp rebuild --msvs_version=2013
```
Now, socket.io should be working.
