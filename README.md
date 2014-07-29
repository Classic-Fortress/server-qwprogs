Classic Fortress v0.9 beta
==========================

New features
------
* Map voting during last few minutes of each game (use /votenext and /forcenext to vote early).
* Map specific configurations (/fortress/cfg/maps/<mapname>.cfg).
* Grenade timers (disable with /cf\_notimers 1 or disable just sound with /cf\_notimersound 1).
* Grenade slot switching (/grenswitch).
* Prime/throw grenades with one button (/gren1 and /gren2).
* Weapon slots (1-4) where 1 is always primary and 4 is always melee.
* Quick attack aliases (+slot1-4).
* Next/previous weapon (/weapprev and /weapnext).
* Last weapon (/weaplast).
* Remember current weapon and last weapon after dying.
* Free suicides (for class changing) during first 10 seconds after spawning.
* Updated class help (bindings, aliases and settings) reachable with /classhelp.
* Dropping flag now possible on all maps using /dropflag.
* Responsive menus and status bar thanks to rewritten menu/sbar code.
* Any non-valid impulse will close the active menu.
* Class configs are now executed from /fortress/classes/ subdirectory.
* Team player count in team selection menu.
* Changing teams is now allowed.
* No more spamming weapon messages.
* Major code cleanup and rewrites.

Scout
------
* New Scanner menu where Scanner settings can be changed.

Sniper
------
* Sniper Rifle range increased.
* Automatic sensitivity scaling while zoomed in.
* Use the special button as a zoom button (cf_zoomkey 1).
* Two sniper zoom modes (2x and 4x) instead of just one.
* Manually adjust fov used in zoom modes with /cf\_fov2x and /cf\_fov4x.
* Reverse sniper zoom order with cf\_reversezoom 1.
* Faster zooming (+/- 20 fov instead of 5 per frame).

Demolitions Man
------
* New detpack menu containing 5, 20, 50 and 255 second detpacks.
* Changed maximum detpipes allowed per team to 6 per demoman instead of 7 total.

Heavy Weapons Guy
------
* Assault Cannon can now be fired while moving.
* Accuracy of Assault Cannon decreased while moving.
* HWGuy can now be affected by concussion grenades while firing Assault Cannon.

Spy
------
* Improved disguise menu.
* Changed class special to silent feign.
* Stop disguising by pressing last weapon bind or the disguise menu bind.

Engineer
------
* Sentry Gun status (health, ammo and level) shown in status bar.
* New Sentry Gun maintenance menu containing simply rotation.
* Upgrade/repair/restock Sentry Gun on spanner hit.
* Repair Dispenser on spanner hit.
* Dismantle Sentry Gun/Dispenser using build menu when standing close.
* Stop building by pressing any weapon slot key or the last weapon key.
* Added message when Dispenser is destroyed.
* Added dismantle message to show how many cells were returned.
* Changed class special to detonate dispenser.
* Engineers can now only dismantle own buildings and rotate own Sentry Gun.
