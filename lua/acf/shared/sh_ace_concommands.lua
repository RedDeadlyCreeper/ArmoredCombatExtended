AddCSLuaFile()

if SERVER then

	concommand.Add( "acf_debris_clear", function(ply)

		if IsValid(ply) and not ply:IsAdmin() then return end

		if not table.IsEmpty(ACE.Debris) then
			for _, debris in ipairs(ACE.Debris) do
				if IsValid(debris) then
					debris:Remove()
				end
			end
		end

	end)

	do

		local function msgToCaller( ply, hud, msg )
			if IsValid(ply) then
				ply:PrintMessage(hud, msg or "")
			else
				print(msg or "")
			end
		end

		concommand.Add( "acf_smokewind", function(ply, _, args)
			local validply = IsValid(ply)
			local printmsg = msgToCaller

			if not args[1] then

				printmsg(ply, HUD_PRINTCONSOLE,

					"Set the wind intensity upon all smoke munitions." ..
					"\n	This affects the ability of smoke to be used for screening effect." ..
					"\n	Example; acf_smokewind 300")

				return false
			end

			if validply and not ply:IsAdmin() then

				printmsg(ply, HUD_PRINTCONSOLE,
					"You can't use this because you are not an admin.")
				return false

			else
					local wind = tonumber(args[1])

					if not wind then
							printmsg(ply, HUD_PRINTCONSOLE, "Command unsuccessful: that wind value could not be interpreted as a number!")
							return false
					end

					ACF.SmokeWind = wind

					net.Start("acf_smokewind")
					net.WriteFloat(wind)
					net.Broadcast()

					printmsg(ply, HUD_PRINTCONSOLE, "Command SUCCESSFUL: set smoke-wind to " .. wind .. "!")
					return true
			end
		end)

		local function sendSmokeWind(ply)
			net.Start("acf_smokewind")
				net.WriteFloat(ACF.SmokeWind)
			net.Send(ply)
		end
		hook.Add( "PlayerInitialSpawn", "ACF_SendSmokeWind", sendSmokeWind )

	end

else

	local function recvSmokeWind()
		ACF.SmokeWind = net.ReadFloat()
	end
	net.Receive("acf_smokewind", recvSmokeWind)

end
