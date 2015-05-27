# Readme

This is my project for b/s programming course. It is a multiplayer game which belongs to the STG (Shoot 'Em Up Games) genre. Two Players each occupy half of the screen, one up, one down. They usually summon servants to attack their opponents rather than directly shooting bullets to allow the gameplay closer to that of The Touhou Project. Of course, player controlled characters have a small collision box. They can focus to reduce the moving speed facilitating dodging bullets.

The game is run in a browser/server architecture. The server side uses Node.js. Most modern browsers should be supported as browser side. Delay should be mostly dealt with by the game's design and synchronization strategies. I am expecting reasonable gameplay with delay less than 100 ms.

## Server configuration:

Use `npm install` in the root directory to install dependencies.
Use `grunt` to automatically compile the client's js files.
Then type `coffee server.coffee` to start the server. By default, it listens port 3000 of localhost.
Visit "http://localhost:3000" to play the game.

**Note** socket.io which I depended on currently cannot be easily installed on Windows 7/8. Here's the quick fix.

```bash
cd node_modules\socket.io\node_modules\engine.io\node_modules\ws
vim package.json # Change the release of nan to 1.6.0
node-gyp rebuild --msvs_version=2013 # I used Visual Studio 2013
```

Now, socket.io should be working.

## Planned Synchronization Strategy

The game is designed so that synchronization is easier and allows longer delay:

- Servants take some time to shoot bullets after they are summoned, so knowledge about a new servant is okay with some delay. Once a servant's state is known, the later shooted bullets will all be known and can be processed locally without communication.
- They are also invincible, so a servant's summoning and behaviour are orthogonal to other events and can be updated to the current time alone without interfering with other elements.
- Interaction cycle between players is long (summoning a servant or shooting some bullets) and their possible movement region is confined to non-intersecting regions, so displaying players with a different delay will not cause trouble in playing.

Here comes the strategy:

Keyboard events are sent from client to server with a timestamp.
Server sends only your opponent's events to you also with a timestamp.

### Client

For clients, your own character, your opponent's servants and bullets are realtime displayed, while your opponent's character, your servants and bullets are displayed delaying for a short period.

Once a new event is received, the client will:
- If its timestamp is later than current time, add it to an event queue.
- Otherwise, simulate only the event to current time and add it.

The only difference between servant/bullet and opponent's movement is that they use different time. The time used by opponent's movement are delayed by a short period of time so that received events usually has a timestamp later than current time.

Only simulating new servants/bullets is okay because of orthogonality stated. The delay is tolerable as summoned servants also have a delay to shoot bullets.

### Server

Server also run a copy of the game to detect whether characters are hitted by a bullet as authorization to prevent cheating. The strategy server uses is similar to clients, but do not delay either side.

### Benefit

The benefit from this strategy should be clear:

- The bullets attacking you and your controls are all realtime.
- You can watch your opponent dodging bullets smoothly without staggering.
- Clients cannot cheat.
- Limited amount of computation needed when you have to rollback and add a new event.