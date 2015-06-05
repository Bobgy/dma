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

Firstly, clients and a server each run a copy of the game. I will describe how information is sent either way.

### Client to Server

Keyboard events will be sent from clients to server with a timestamp. Usually, the time is definitely in the past, then the server can only roll back, apply the event and then fastfoward to current time. These steps are quite complicated and require additional memory and computation. Luckily, a little trick can avoid rolling back and achieve almost the same performance.

That is, clients should be asked to simulate the game a little earlier than the server. Then when server receives a keyboard event from a client, that event should still happen in the "future", and pushed into an event queue to be processed.

If things do not work out as expected such that an event's timestamp is earlier than the server's time, then the event will be applied right now. The problem is that from now on the client will be deviating from the server. A low-frequency synchronization should ensure clients do not deviate too far. Hopefully, by careful managing the time clients simulate in advance, things like this should rarely happen.

On the other hand, only keyboard events are sent to the server, so the potential of cheating is quite limited.

Server sends events caused by your opponents also with a timestamp. There will always be a delay, so your client will extrapolate the information and predict where things will be now.

### Server to Client

Besides sending screenshots at a low frequency to pull back deviating clients, sending events caused by other clients is also a job of the server.

Now that clients simulate earlier than server, broadcasting keyboard events to other players is not feasible, because clients have to rollback and apply these events which we try to avoid.

However, sending back new states of the entities affected by these keyboard events is feasible. Then a client only need to fast forward a single entity to the client's time. The number of entities required to send should be small for this game. Movements will only affect the player and 'Summon' will only affect the summoned servant.

Shadow following should also be applied to your opponent's character to reduce the jitter.

### Pros

- The bullets attacking you and your controls are all real-time.
- You can watch your opponent dodging bullets smoothly.
- Cheating potential is limited.
- Only one copy of the game need to be maintained on either side.
- Easier to implement (at least for me)
- Allow loose cohesion between the synchronization module and the game module

### Cons

- Your opponent's behavior is not absolutely accurate. It will be quite usual to see your opponent go through bullets alive.
- Fast forwarding in clients may be CPU time consuming.

### Update Note

I was planning to let clients display opponents' movement and servants/bullets you send with a delay so that you can see your opponent's movement accurately, but now I give up this idea.

This is because I cannot think of a way to loose the cohesion between synchronization and game logic. I prefer writing game logic without strong cohesion with other modules than displaying oppponents accurately.

By the way, inform me if you have a better idea either on displaying opponents' movement accurately or designing the architecture to loose the cohesion.
