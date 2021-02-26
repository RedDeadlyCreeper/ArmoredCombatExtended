------------------
-- INSTALLATION --
------------------

- Recommended installation: SVN
  If you don't have a svn program, TortoiseSVN is a good one. http://TortoiseSVN.net
  This walkthrough assumes you are using TortoiseSVN, and have it installed already.
 
  Go to your garrysmod addons folder ( \SteamApps\common\GarrysMod\garrysmod\addons ), create a new
  folder named ACE, then right click it and choose "SVN Checkout".  In the "URL of repository" box, put
  "https://github.com/RedDeadlyCreeper/ArmoredCombatExtended/trunk" (without the "") and click OK.  ACF is a fairly large addon,
  so it will take some time to download.
  
  Once you have finished the download to your desired folder, just close the svn window and you can start using the addon. In case of
  you want to update the ACE SVN to latest version, simply right click the ACE folder and choose "SVN Update", this works for restoring parts of addon
  just if you miss some of them. This is recommended because updates generally updates some files of ACE and not 
  the entire addon (meaning less time downloading than the not recommended way indicated below)
  
- NOT Recommended installation: Zip
  If you're having problems with SVN, you can download a zip file directly from github and put its folder inside of addons folder.  However, this
  is NOT RECOMMENDED since ACE is more than 1 gb addon and you will have to download it entirely for updates.
  
  Go to https://github.com/RedDeadlyCreeper/ArmoredCombatExtended and click the "Download Zip" button on the right side of the page.
  If you don't have an ACF folder inside your addons, create one.  Open the zip, go into the "ACF-Master"
  folder, and extract all the files into your ACF folder in addons.  The folder structure should look
  like "garrysmod\addons\ACF\lua" and NOT "garrysmod\addons\ACF\ACF-Master\lua".

------------------------------
-- NOTES ABOUT INSTALLATION --
------------------------------

- If you are updating a previous installation of ACF and you're having issues with 
  vanilla particles (fire, blood) not showing up, delete your garrysmod/particles/
  directory.

- It is not necessary to copy the scripts or particles directories anymore.

- KEEP IN MIND, IF YOU HAVE ISSUES DURING THE INSTALLATION OF THIS ADDON, VISIT US ON DISCORD, NOT ON GITHUB!
  Our discord is a more active place for general conversations about ACE and things like that
  You can join our discord here: https://discord.gg/Y8aEYU6
  
- We have a wiki that contains information about ACE features, that you can visit using this link: https://github.com/RedDeadlyCreeper/ArmoredCombatExtended/wiki
  
- If you're into ACF combat, Knight Icy had an excellent extra sound pack for weapons on the GMod workshop. However that was taken down so twisted has uploaded it again
  Check the upload out at https://steamcommunity.com/sharedfiles/filedetails/?id=1596532339&searchtext=acf+sounds


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
