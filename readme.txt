------------------
-- INSTALLATION --
------------------

- Recommended installation: SVN
  If you don't have a svn program, TortoiseSVN is a good one. http://TortoiseSVN.net
  This walkthrough assumes you are using TortoiseSVN, and have it installed already.
  
  Go to your garrysmod addons folder ( \SteamApps\common\GarrysMod\garrysmod\addons ), create a new
  folder named ACF, right click it and choose "SVN Checkout".  In the "URL of repository" box, put
  "https://github.com/nrlulz/ACF/trunk" (without the "") and click OK.  ACF is a fairly large addon,
  so it will take some time to download.
  
  If you want to update the ACF SVN at some point, right click the ACF folder in your addons and choose
  "SVN Update".
  
- Last resort installation
  If you're having problems with SVN, you can download a zip file directly from github.  However, this
  is NOT RECOMMENDED as it's a large, slow download, has a LOT of extra unused stuff which bloats the zip,
  and you have to redownload the entire thing if you want to update ACF.
  
  Go to https://github.com/nrlulz/ACF and click the "Download Zip" button on the right side of the page.
  If you don't have an ACF folder inside your addons, create one.  Open the zip, go into the "ACF-Master"
  folder, and extract all the files into your ACF folder in addons.  The folder structure should look
  like "garrysmod\addons\ACF\lua" and NOT "garrysmod\addons\ACF\ACF-Master\lua".

- If you are updating a previous installation of ACF and you're having issues with 
  vanilla particles (fire, blood) not showing up, delete your garrysmod/particles/
  directory.

- It is not necessary to copy the scripts or particles directories anymore.

- IF YOU ARE HAVING INSTALLATION PROBLEMS, PLEASE POST ON THE FACEPUNCH ACF THREAD, NOT ON GITHUB.
  Please only create an issue on github if you've found a bug, or have a suggestion.  The FP forum thread
  is a good place for general ACF conversation, suggestions, and help requests.
  Forum thread: https://facepunch.com/showthread.php?t=1548397
  
- If you're into ACF combat, Knight Icy has an excellent extra sound pack for weapons on the GMod workshop.
  Check it out at http://steamcommunity.com/sharedfiles/filedetails/?id=301482990


---------------------------------------------------------------
-- IF YOU WANT ACF POWERED STUFF TO GO MORE REALISTIC SPEEDS --
---------------------------------------------------------------

Put these two lines in your server.cfg:

lua_run local tbl = physenv.GetPerformanceSettings() tbl.MaxAngularVelocity = 30000 physenv.SetPerformanceSettings(tbl)
lua_run local tbl = physenv.GetPerformanceSettings() tbl.MaxVelocity = 20000 physenv.SetPerformanceSettings(tbl)

This will raise the angular velocity limit (wheels spinning) and forward speed limit.


--------------------
-- FOR DEVELOPERS --
--------------------

Frankess has added some handy hooks that can be used to limit damage and explosions
and such. They are as follows:

ACF_BulletsFlight( Index, Bullet )
	Return false to skip checking if the bullet hit something
	Args:
	- Index (number): the bullet's index
	- Bullet (BulletData): the bullet object
	
ACF_BulletDamage( Type, Entity, Energy, Area, Angle, Inflictor, Bone, Gun, IsFromAmmo )
	Return false to prevent damage
	Args:
	- Type (string): the ACF entity type (prop/vehicle/squishy)
	- Entity (entity): the entity being hit
	- Energy (table): kinetic energy
	- Area (number): area in cm^2
	- Angle (number): angle of bullet to armor
	- Inflictor (player): owner of bullet
	- Bone (number): the bone being hit
	- Gun (entity): the gun that fired the bullet
	- IsFromAmmo (boolean): true if this is from an ammo explosion (don't think this is implemented yet)

ACF_KEShove( Target, Pos, Dir, KE )
	Return false to prevent kinetic shove
	Args:
	- Target (entity): the entity being shoved
	- Pos (vector): the position the shove is applied from
	- Dir (vector): the direction of the shove
	- KE (number): force of the shove in KJ
	
ACF_FireShell( Gun, Bullet )
	Return false to prevent gun from firing
	Args:
	- Gun (entity): the gun in question
	- Bullet (BulletData): the bullet that would be fired
	
ACF_AmmoExplode( Ammo, Bullet )
	Return false to prevent ammo crate from exploding
	Args:
	- Ammo (entity): the ammo crate in question
	- Bullet (BulletData): the bullet that would be fired
	
ACF_FuelExplode( Tank )
	Return false to prevent fuel tank from exploding
	Args:
	- Tank (entity): the fuel tank in question
	
ACF_CanRefill( Refill, Ammo )
	Return false to prevent ammo crate from being refilled (not yet implemented)
	
	
	
------------------------
Damage Protection hooks:

ACF_PlayerChangedZone
	This hook is called whenever a player moves between the battlefield and a safezone, or between safezones.
	This hook is called regardless of damage protection mode e.g. during build mode where safezones are irrelevant.
Args;
	ply		Player:	The player who has just transitioned from one zone to another.
	zone	String:	The name of the zone which the player has moved into (or nil if moved into battlefield)
	oldzone	String:	The name of the zone which the player has exited (or nil if exited battlefield)


ACF_ProtectionModeChanged
	This hook is called whenever the damage protection mode is altered.
	This hook is also called once at startup, when the damage protection mode is initialized to "default" (oldmode = nil during this run).
Args;
	mode	String:	The name of the newly activated damage protection mode.
	oldmode	String:	The name of the damage protection mode which has just been deactivated.
	
	

-----------------------
Bullet table callbacks:

For the argument list (Index, Bullet, FlightRes):
	Index: Index of the bullet in the bullet-list.
	Bullet: The bullet data table.
	FlightRes: The results of the bullet trace.
- - - - - -

OnEndFlight(Index, Bullet, FlightRes)
	called when a bullet ends its flight (explodes etc)
	
OnPenetrated(Index, Bullet, FlightRes)
	when a bullet pierces the world or an entity

OnRicochet(Index, Bullet, FlightRes)
	when a bullet bounces off an entity

PreCalcFlight(Bullet)
	just before the bullet performs a flight step

PostCalcFlight(Bullet)
	just after the bullet performs a flight step

HandlesOwnIteration 
	this is just a key: put it into the bullet table to prevent ACF from iterating the bullet.  You can then iterate it yourself in different places.


---------------------
Engine model scaling:

V engines
Large 	1.0
Medium 	0.665
Small 	0.532

Inline engines
Large	1.0
Medium	0.6
Small	0.4
