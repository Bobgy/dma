## Synchronization Strategy

The game is designed so that synchronization is easier and allows longer delay:

- Servants take some time to shoot bullets after they are summoned, so knowledge about a new servant is okay with some delay. Once a servant's state is known, the later shooted bullets will all be known and can be processed locally without communication.

- They are also invincible, so a servant's summoning and behaviour are orthogonal to other events and can be updated to the current time alone without interfering with other elements.

- Interaction cycle between players is long (summoning a servant or shooting some bullets) and their possible movement region is confined to non-intersecting regions, so displaying players with a different delay will not cause trouble in playing.

Here comes the strategy:

Firstly, clients and a server each run a copy of the game. I will describe how information is sent either way.

### Client to Server

Keyboard events will be sent from clients to server with a timestamp. The timestamp would obviously be in the past when receiving, then the server can only roll back, apply the event and fast-forward to the current time.

These steps are quite complicated and require additional memory and computation. Luckily, a little trick can avoid rolling back and achieve almost the same performance.

That is, let clients simulate the game a little earlier than the server. Then when a server receives a keyboard event from a client, that event should still be happening in the "future". Now the server can push it into an event queue to be processed later.

If things do not work out as expected such that an event's timestamp is earlier than the server's time, then the event will be applied right now. The problem is that from now on the client will be deviating from the server. Low-frequency synchronization should ensure clients do not deviate too far. Hopefully, by careful managing the time clients simulate in advance, things like this should rarely happen.

On the other hand, only keyboard events are sent to the server, so the potential of cheating is quite limited.

Server sends events caused by your opponents also with a timestamp. There will always be a delay, so your client will extrapolate the information and predict where things will be now.

### Server to Client

Besides sending screenshots at a low frequency to pull back deviating clients, sending events caused by other clients is also a job of the server.

Now that clients simulate earlier than server, broadcasting keyboard events to other players is not feasible, because clients have to rollback and apply these events which we try to avoid.

However, sending back new states of the entities affected by these keyboard events is feasible. Then a client only need to fast forward a single entity to the client's time. The number of entities required to send should be small for this game. Movements will only affect the player and 'Summon' will only affect the summoned servant.

### Two Worlds

Note that interactions mostly happen between a player and its enemy's bullets and servants. So the game may be simulated in two separated worlds, each containing one player and its enemies. The two worlds may be simulated at a different pace. The world containing the character you control should be real-time while the other world can delay and act like a play-back of your enemy's actions.

Shadow following should also be applied to your opponent's character to reduce the jitter. (Not yet implemented)

### Pros

- The bullets attacking you and your controls are all real-time.
- You can watch your opponent dodging bullets smoothly.
- Cheating potential is limited.
- Only one copy of the game need to be maintained on either side.

### Cons

- Your opponent's behavior is delayed.
- Fast forwarding in clients may be CPU consuming.
