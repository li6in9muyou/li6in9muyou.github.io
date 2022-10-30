---
title: 重构代码练习。apply clean architecture on a python tutorial codebase
date: 2022-06-12
categories: [Learning]
tags: [socket, python, clean-architecture]
---

# What are we building

In this [tutorial](https://youtu.be/-3B1v-K1oXE) on implementing multiplayer online game in [pygame](https://www.pygame.org/docs/), the presenter [Tim](https://www.youtube.com/c/TechWithTim) developed a two player online game where local player moves a square on the screen with keyboard the the position of the square controlled by a remote player is synced via a custom designed communication protocol based on TCP.

The communication protocol is outlined below:

0. when a client connects to the server, it's assigned with an id. First client connects to the server gets a id of 0, the other gets 1.
1. when client sends the coordinates of its player to the server, server replies with the coordinates of the other player. The format used here is `<id>:<x>,<y>`, for example, `0:50,60` which means client with id of 0 reports that its square is at coordinates (50,60).

# Initial state of the codebase

Before game loop starts, the `Game` object creates two `Player` instances and `Canvas` instance. In the game loop, the `Game` object checks whether relevant keys are pressed then calls `Player.move` on the instance that represents the local player. After handling inputs, it syncs the coordinates of the other `Player` with the server.

```python
# Game.run

if keys[pygame.K_RIGHT]:
    if self.player.x <= self.width - self.player.velocity:
        self.player.move(0)

if keys[pygame.K_LEFT]:
    if self.player.x >= self.player.velocity:
        self.player.move(1)

if keys[pygame.K_UP]:
    if self.player.y >= self.player.velocity:
        self.player.move(2)

if keys[pygame.K_DOWN]:
    if self.player.y <= self.height - self.player.velocity:
        self.player.move(3)

# Send Network Stuff
self.player2.x, self.player2.y = self.parse_data(self.send_data())

# Update Canvas
self.canvas.draw_background()
self.player.draw(self.canvas.get_canvas())
self.player2.draw(self.canvas.get_canvas())
self.canvas.update()
```

Notice that `Game` calls `Player.draw` to draw sprites on the screen.

# My refactoring

In short, this game models two sprites moving in an arena.

## Domain Objects

Domain objects includes `Arena` and `Player`.

### `Arena`

```python
class Arena:
    def __init__(self, width, height, players):
        self.players = players
        self.width = width
        self.height = height
        self.ground_color = (255, 255, 255)
```

### `Player`

```python
class Player:
    def __init__(self,
                 init_x=-1,
                 init_y=-1,
                 color=(100, 100, 100)):
        self.color = color
        self.x = init_x
        self.y = init_y
        self.velocity = 2

    def move(self, direction):
        ...
```

## Use cases

The primary use cases are

- user may press keyboard to move its square
- the position of other user's square is updated in real time

I designed `ArenaMoveService` to implements these two use cases.

### `.player_move(player, direction)`

For the first use case, `ArenaMoveService.player_move(player, direction)` mutates `Player` object passed in and calls `self.port.dump(self.arena, self.players)` to output game state.

```python
def set_coord(self, player, x, y):
    def clip(value, upper, lower=0):
        if value >= upper:
            return upper
        if value <= lower:
            return lower
        return value

    player.x = clip(x, self.arena.width)
    player.y = clip(y, self.arena.height)
    self.port.dump(self.arena, self.players)
```

### `.set_coord(player, x, y)`

For the second use case, due to limitation of the communication protocol, moving direction of the remote player is not conveniently known, `ArenaMoveService.set_coord(player, x, y)` directly sets one sprite's coordinates.

> Moving directions of the remote player can be obtained by differencing last known position and the latest position. Calculate its moving direction then calls `Player.move` on the remote player's sprite is a better approach because it will ensure two sprites move in consistent manner.

```python
def player_move(self, player, direction):
    if direction == 0:
        if player.x <= self.arena.width - player.velocity:
            player.move(0)

    if direction == 1:
        if player.x >= player.velocity:
            player.move(1)

    if direction == 2:
        if player.y >= player.velocity:
            player.move(2)

    if direction == 3:
        if player.y <= self.arena.height - player.velocity:
            player.move(3)
    self.port.dump(self.arena, self.players)
```

## Adapters

External actors of this system includes a local user and a remote user.

Considering the loop-based nature of this video game system, I designed the interface of adapters as follows:

```typescript
interface IAdapter {
  on_update(elapsed: number): void;
  on_init(context: Context): void;
}
```

`IAdapter.on_update` will be called on every rendering cycle.

### `KeyboardInputAdapter`

It checks key presses then call `AreneMoveServie`

```python
def on_update(self):
    keys = pygame.key.get_pressed()
    if keys[pygame.K_RIGHT]:
        self.arena_move_service.player_move(self.player, 0)
    if keys[pygame.K_LEFT]:
        self.arena_move_service.player_move(self.player, 1)
    if keys[pygame.K_UP]:
        self.arena_move_service.player_move(self.player, 2)
    if keys[pygame.K_DOWN]:
        self.arena_move_service.player_move(self.player, 3)
```

### `OnlineAdapter`

It sends position of local player's sprite and updates that of remote player's.

```python
def on_update(self):
    data = f"{self.local_player_id}:" \
           f"{self.local_player.x},{self.local_player.y}"
    self.client.send(str.encode(data))
    self.arena_service.set_coord(self.remote_player, *self.parse_data(self.client.recv(2048).decode()))
```

## Ports

In this system, the only port is `PyGameRenderPort` that render sprites to the screen. In the following code, `arena` and `players` captures the entire game state.

### `PyGameRenderPort`

```python
def dump(self, arena, players):
    self.screen.fill(arena.ground_color)
    for player in players:
        pygame.draw.rect(
            self.screen,
            player.color,
            (player.x, player.y, 50, 50)
        )
    pygame.display.update()
```

# Thoughts

## Infinite Recursion Bug

### exposition

In effect, the `OnlineAdapter` is responsible for both sending local state to server and updating local copy of remote state. The first responsibility ports system state to a external actor while the second mutates system state and invokes method on `ArenaMoveService`.

Hence, component with these two responsibilities may be considered a "port" as well as an "adapter". At first, I decided to put it in an output port, like so:

```python
def dump(self, *_):
    data = f"{str(self.id)}:{str(self.local_player.x)},{str(self.local_player.y)}"
    self.client.send(str.encode(data))
    reply = self.client.recv(2048).decode()
    self.arena_move_service.set_coord(self.remote_player, *parse_data(reply))
```

Not before long, I discovered that code snippets above causes stack overflow because maximum recursion depth exceeds.

### analysis

I made two mistakes here.

For one, this output port is calling a service which violates the clean architecture principles dictating that flow of control should starts from services then points outwards to ports.

For another, more generally, when `dump()` is called, it makes query to system state and subsequently mutates it, which leads to another invocation of `dump()`.

### solution

One simple solution to this is to make updates only when something has actually changed. In following code snippets, `dump()` makes the mutating call conditionally after comparing previous state and current state. I employed this solution at first.

```python
    def dump(self, *_):
        data = f"{str(self.id)}:{str(self.local_player.x)},{str(self.local_player.y)}"
        self.client.send(str.encode(data))
        now_remote_x, now_remote_y = parse_data(self.client.recv(2048).decode())

        if self.prev_remote_x != now_remote_x or self.prev_remote_y != now_remote_y:
            self.arena_move_service.set_coord(self.remote_player, now_remote_x, now_remote_y)
            self.prev_remote_x = now_remote_x
            self.prev_remote_y = now_remote_y
```

Another solution would be move remote synchronization logic in an adapter where it's appropriate to call `ArenaMoveService` as shown above.
