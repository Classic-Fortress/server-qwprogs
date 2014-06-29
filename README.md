Classic Fortress v0.1 beta

=== New features ===
* Grenade timers.
* Grenade slot switching.
* Weapon slots (1-4).
* Next/previous weapon.
* Last weapon.
* Sensitivity scaling upon sniper zooming.
* Sniper zoom key which zooms in regardless of sniper rifle status (setinfo zk 1).
* Two sniper zoom modes (2x and 4x) which can be manually set with setinfo z2x and z4x.
* Reverse sniper zoom order with setinfo zr 1.
* New scout scanner menu.
* New demoman detpack menu.
* New sentry gun rotation menu.
* Stop building/disguising upon pressing "last weapon" bind.

=== Improved ===
* Improved consistent grammar.
* Remember current weapon and last weapon after dying.
* Team player count in team selection menu.
* Sniper smooth zooming is now a lot faster (disable smooth zooming with setinfo zi 1).
* More responsive menus (rewritten menu code).
* No more sbar blinking (rewritten sbar code).
* Revised dispenser use menu.
* Revised sentry gun menu.
* Revised engineer build menu.
* Revised spy disguise menu.
* Overall improved menus.
* Allow engineer build menu to be opened even while in the air.
* Engineers can now only dismantle their own buildings.
* Engineer dismantle messages show how many cells you got back.

=== Changed ===
* Max 6 active demoman pipes allowed (down from 7).
* No limit to team pipes/flares/ammoboxes.
* Engineer can only rotate own sentry.
* Remove decimals from sentry gun status.
* Class configs are now executed from /fortress/classes/ subdirectory.
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
* Fixed the spamming weapon messages (e.g. Tranquiliser gun selected).
* Fixed the sentry gun menu to not close prematurely.
* Fixed broken ammo display.
* Fixed endless intermission bug.
* Fixed bug where players got stuck in intermission mode upon map change and hence could not respawn.
* Major code cleanup and rewrites.