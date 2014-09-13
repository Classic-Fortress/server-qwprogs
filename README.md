Classic Fortress v0.9 beta
==========================

New features
------
* Map vote (4 random maps + current map) during last few minutes of game (shown for newly spawned or toggled with /togglevote).
* Force early map vote using /votenext, /votetrick (trick maps) and /voterace (race maps).
* Force map switch to the voted map early using /forcenext.
* Auto ID feature (cf\_autoid 1 = on, 2 = teammates only, 3 = enemies only).
* Show friendly Sentry Gun health in /id for Engineers.
* Show max health and max armor in /id for Medics and Engineers.
* Grenade timers (disable with /cf\_notimers 1 = no timers, 2 = no timer sound).
* Grenade slot switching (/grenswitch).
* Prime/throw grenades with one button (/gren1 and /gren2).
* Weapon slots (1-4) where 1 is always primary and 4 is always melee.
* Quick attack aliases (+slot1-4).
* Next/previous weapon (/weapprev and /weapnext).
* Last weapon (/weaplast).
* Remember current weapon and last weapon after dying.
* Reload all weapon slots using /reloadnext (one at a time).
* Drop hand grenade to ground if primed when dying.
* Drop grenades in backpack.
* Don't pick up unusable ammo from discarded backpacks (note: this only applies to /discarded backpacks).
* Don't telefrag teammates when spawning.
* Free class switch during first 10 seconds after spawning.
* Updated class help (bindings, aliases and settings) reachable with /classhelp.
* Dropping flag now possible on all maps using /dropflag.
* Class configs are now executed from /fortress/classes/ subdirectory.
* When using class configs, /fortress/classes/default.cfg gets executed first.
* Team player count in team selection menu.
* Class player count (and class restrictions) in class selection menu.
* Changing teams is now allowed.
* Responsive menus and status bar thanks to rewritten menu/sbar code.
* Clip ammo in status bar ticks up during reload.
* Kill streak and personal cap count in status bar.
* Option to spawn with full ammo and armor.
* Map specific configurations (/fortress/cfg/maps/<mapname>.cfg).
* Major code cleanup and rewrites.

Scout
------
* New special ability "dash" will initiate a bunny hop at 540 speed.
* New Scanner menu where Scanner settings can be changed.
* Caltrop Canisters no longer "explode" in your hands.
* Remember Scanner status across deaths.

Sniper
------
* Sniper Rifle range increased.
* Automatic sensitivity scaling while zoomed in.
* Use the special button as a zoom button.
* Use mouse wheel to adjust zoom while zoomed in.
* Sniper Rifle now needs to be reloaded between shots.

Demolitions Man
------
* New detpack menu containing 5, 20, 50 and 255 second detpacks.
* Changed maximum detpipes allowed per team to 6 per demoman instead of 7 total.
* Decrease /detpipe cooldown to 0.5 seconds instead of 0.8.
* Stop detpacking by pressing last weapon bind.

Combat Medic
------
* Healing aura that heals 5 hp every second to friendly players within range (120 units), only active when cells >= 50.
* Medikit now heals friendly targets to max health + 50, consuming all cells.
* Cells automatically regenerate at 10 cells per second.
* Bioweapon now does 7 damage per second to enemies, up from 7 damage per 3 seconds.

Heavy Weapons Guy
------
* Assault Cannon can now be fired while moving and while jumping.
* Accuracy of Assault Cannon decreased while moving.
* HWGuy can now be affected by concussion grenades while firing Assault Cannon.
* New class special that stops the Assault Cannon from firing and just keeps it spinning.
* Lowered volume for spinning Assault Cannon.

Pyro
------
* Add knockback to Flamethrower.

Spy
------
* Improved disguise menu.
* Change color and skin in one sequence.
* Last disguise (reachable through disguise menu or using /dlast alias).
* Stop disguising by pressing last weapon bind.
* New aliases for changing team color (/denemy (if 2 teams), /dblue, /dred, /dyellow, /dgreen).
* New aliases for changing skin (/dscout, /dsniper, /dsoldier, etc).
* Build your own disguise aliases (e.g. alias bsniper "dblue; wait; dsniper" for blue sniper).
* Spy can now feign death in air.
* Spy now drops an empty backpack when feigning death.
* A fake death message (but relevant to current situation) is now shown when feigning death.

Engineer
------
* Sentry Gun status (health, ammo and level) shown in status bar.
* New Sentry Gun maintenance menu containing simply rotation.
* Upgrade/repair/restock Sentry Gun on spanner hit.
* Dispenser automatically stocks nearby team members.
* Dispenser restock rate increases with more players on team.
* Rocket ammo in Dispenser increase explosions more than before.
* Repair Dispenser on spanner hit.
* Dismantle Sentry Gun/Dispenser using build menu when standing close.
* Stop building by pressing last weapon key.
* Added message when Dispenser is destroyed.
* Added dismantle message to show how many cells were returned to Engineer.
* Changed class special to detonate dispenser.
* Engineers can now only dismantle own buildings and rotate own Sentry Gun.
* Railgun no longer penetrates targets.
