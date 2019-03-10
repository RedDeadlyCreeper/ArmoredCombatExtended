include("gitrc.lua")


ACFM_VersionStatus = nil


net.Receive( "acfm_versioncheck", function( len, ply )
	
	net.Start("acfm_versionresponse")
	net.WriteTable(ACFM_VersionStatus or {})
	net.Send(ply)
	
end )



function ACF_Missiles_VersionCheck()

    -- make sure version checker only runs for people who've installed the mod.
    if file.Exists("ACFMissiles_VCheck.txt", "GAME") then
        GitRC.CheckVersion("Bubbus", "ACF-Missiles", function(data)
			
			ACFM_VersionStatus = 
			{
				IsLatest = data.uptodate,
				LatestDate = data.committime
			}
			
        end)
    end

end


hook.Add( "Initialize", "acfm_versioncheck", function(move)
    
	util.AddNetworkString("acfm_versioncheck")
	util.AddNetworkString("acfm_versionresponse")
	
    timer.Simple(1, ACF_Missiles_VersionCheck)
    
end )