FortressOne Lag Compenstation
=========
FortressOne supports lag compensation to improve player experience when playing across continents or across oceans.

tl;dr
--
```
rcon sv_antilag 1
rcon localinfo project_weapons on
```

There are two types of lag compensation available, and these are configured at the server level. 

Hitscan weapons
---------------
Enabled with: ```sv_antilag 1``` (default: 0)

Hitscan weapons are weapons where an instant trace is emitted from the attacker in the direction they are shooting. In FortressOne, this means the shotgun and super-shotgun only. 

Hitscan weapons use a rollback mechanism based on antilag support in FTE. This means that players can aim using their crosshair without compensating for latency, as it would be if they were playing on a local server.

To enable, set sv_antilag to 1.

Projectile weapons 

------------------

- Enabled with: ```localinfo project_weapons on``` (default: off)
- Configurable: ```localinfo project_weapons_max_latency``` (default: 0.1)

Projectile weapons are everything else. These are weapons which emit a projectile with a velocity that travel through space, eventually impacting on a player or the environment. 
In FortressOne, projectiles can be fast-forwarded, or 'projected' forward based on the ping of the player shooting the rocket. This means that a player on a ping with 100ms will have their projectiles origin fast-forwarded to the point that they would have spawned if the player had zero latency. 

For example:
Rockets travel at 900units / second.

A player with 0ms ping has the rocket launcher out and clicks the shoot. The server immediately receives the message and spawns the rocket. 500ms after clicking the shoot button, the rocket will be 450units away from the player. 

A player with a 100ms ping has the rocket launcher out and clicks to shoot. The server receives the message 50ms later. Without projectile fast-forwarding, after 500ms since clicking the shoot button, the projectile will be only 405units away from the player after the button was clicked - it has only had 450ms of existence and therefore 450ms of travel time. 

With project_weapons turned on, FortressOne will calculate where the rocket would be if it was spawned 50ms ago (in this case 45 units from player), and then regular handling of projectile motion takes over. 

This means that 500ms from the player clicking the shoot button, the rocket is 45 units (spawn position) + 405 (450ms * 900) units from the player position - 450 - ie, the same position had the player had 0 ping. 

