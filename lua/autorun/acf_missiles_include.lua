AddCSLuaFile()

AddCSLuaFile("autorun/acf_missile/folder.lua")
include("autorun/acf_missile/folder.lua")

AddCSLuaFile("acf/shared/acf_missileloader.lua")
include("acf/shared/acf_missileloader.lua")

AddCSLuaFile("acf/shared/acfm_globals.lua")
include("acf/shared/acfm_globals.lua")

AddCSLuaFile("autorun/client/cl_acfm_versioncheck.lua")
AddCSLuaFile("autorun/client/cl_acfm_menuinject.lua")
AddCSLuaFile("autorun/client/cl_acfm_effectsoverride.lua")
AddCSLuaFile("autorun/printbyname.lua")
AddCSLuaFile("acf/client/cl_acfmenu_missileui.lua")

if SERVER then

  include("gitrc.lua")

end

AddCSLuaFile("includes/modules/markdown.lua")
AddCSLuaFile("acf/client/cl_missilewiki.lua")
AddCSLuaFile("autorun/client/acfm_wiki.lua")


AddCSLuaFile("acf/shared/sh_acfm_getters.lua")
AddCSLuaFile("autorun/sh_acfm_roundinject.lua")

AddCSLuaFile("autorun/sh_acfm_cvars.lua")
include("autorun/sh_acfm_cvars.lua")

game.AddParticles( "particles/flares_fx.pcf" )
PrecacheParticleSystem( "ACFM_Flare" )
