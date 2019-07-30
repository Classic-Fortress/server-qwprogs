FortressOne Server v0.1.0
==========================

New features
------
* `info_empblock` has a new field `goal_effects`. Setting it to 16 will prevent it from blocking emps if there is a wall between it and the explosion.
* New map point entity `info_empblock` with `t_length` field that specifies its radius of effect. An EMP explosion within a range of one will not go through walls.
* Server option for duelmode to respawn with all grens `localinfo duel_all_grens 1`/`localinfo dag 1`
* Server option to remove packs in duel mode `localinfo duel_no_packs 1`/`localinfo dnp 1`
* Server setting for duelmode reset delay `localinfo drd 0.5` (`localinfo duel_reset_delay 0.5`)
* Admin option to enable duel mode. Will auto-reset/resup the not dead player. Main option - `localinfo duelmode on`
* Server option for making all walls block EMP. Off by default. `localinfo walls_block_emp 1` or `localinfo wbe 1`. (SPAWNFLAG_BLOCK_EMP 4096 will work regardless)
* Server option for setting detpack to solid (blocking). Off by default. `localinfo solid_detpack 1` or `localinfo sdp 1`.
* Server option for overriding map class restrictions (except civilian). `serverinfo override_mapclasses 1` or `serverinfo omc 1`.
* Option for maximum grenades for all classes. `localinfo max_gren1_<class> <number>`, short `localinfo mg1_<classnum> <number>`. Works for gren1s and gren2s. Eg `localinfo max_gren1_scout 0` to remove caltrops or `localinfo mg2_9 2` to reduce max EMPs to 2.
* Option to fully restock player's clip and finish reload immediately if in progress. `localinfo stock_reload 1` (`localinfo srd 1`) will trigger only on flag capture (with stock_on_cap enabled). `2` will trigger whenever any tfgoal gives you the appropriate ammo.
* Option for statusbar flaginfo. `setinfo sbflaginfo 1` (default). Setting it to `2` will skip the tf tips on respawn and show flag info all the time.
* Admin system created to allow for easy setup of pub/pug/quad/duel games, kick players etc `localinfo adminpwd <password>` and `cmd adminpwd <password>; wait; adminmenu`
* Loc support added to server, show locations for dropped flag.
* Nailgrenades changed to "Shock/Laser Grenades" to lower spam/not stop bunnyhopping on hit (0 original, 1 laser, 2 burst). `localinfo nailgren_type 1` and `nginfo` in game for all configurable settings.
* Option for hitsounds (1 - enemies only, 2 - enemies and teammates). `setinfo hitsound 2`
* Option for medic to be immune from concussion effects. `localinfo medicnocuss on`.
* Option to adjust concussion grenade effect time in seconds. `localinfo cussgrentime n`.
* Increased nail velocity. Disable with `localinfo old_ng_velocity on`.
* Nailgun and Super-nailgun damage configurable with `localinfo ng_damage` and `localinfo sng_damage`.
* Keys and flags glow their colour.
* Option to adjust conussion grenade effect time in seconds. `localinfo cussgrentime`.
* Option to fully restock player on cap. `localinfo stock_on_cap on`.
* Option for packs to fully restock health and armour of player. `localinfo stockfull on`.
* Automatic server-side mvd recording of clan matches. Requires `localinfo serverdemo on`.
* Map vote (4 random maps + current map) during last few minutes of game (shown for newly spawned or toggled with /togglevote).
* Force early map vote using /votenext, /votetrick (trick maps) and /voterace (race maps).
* Force map switch to the voted map early using /forcenext.
* Auto ID feature (cf\_autoid 1 = on, 2 = teammates only, 3 = enemies only).
* Show friendly Sentry Gun health in /id for Engineers.
* Show max health and max armor in /id for Medics and Engineers.
* Grenade timers (disable with `setinfo nt 1` for no timers, or `setinfo nt 2` for no timer sound).
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
* Allow team changing.
* Any non-valid impulse now closes the active menu.


== Removed ===
* Removed weapon messages for weapons without weapon modes.
* Removed bioweapon (merged into medikit).
* Removed grapple hook.
* Removed birthday mode.
* Removed engineer mortar (not used anymore).
* Removed bindings menu.
* Removed class help.

=== Fixed ===
* Don't allow building in prematch.
* Gas no longer goes through walls.
* Fixed the spamming weapon messages (e.g. Tranquiliser gun selected).
* Fixed the sentry gun menu to not close prematurely.
* Fixed broken ammo display.
* Fixed endless intermission bug.
* Fixed bug where players got stuck in intermission mode upon map change and hence could not respawn.
* Major code cleanup and rewrites.
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
* Automatic sensitivity scaling while zoomed in.  Use the special button as a zoom button.  Use mouse wheel to adjust zoom while zoomed in.  Sniper Rifle now needs to be reloaded between shots.  

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
* Repair Dispenser on spanner hit.
* Dismantle Sentry Gun/Dispenser using build menu when standing close.
* Stop building by pressing last weapon key.
* Added message when Dispenser is destroyed.
* Added dismantle message to show how many cells were returned to Engineer.
* Changed class special to detonate dispenser.
* Engineers can now only dismantle own buildings and rotate own Sentry Gun.


Compilation
------
Compile with [FTEQCC](http://fte.triptohell.info/downloads)

Ensure that `fteqcc64` is available in `$PATH` and:

```
$ make
```
