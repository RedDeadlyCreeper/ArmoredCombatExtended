

if CLIENT then

	--Copied from garrysmod CalcVehicleView function, to allow acf ents to be included into the filter
	function ACE_CalcVehicleView( Vehicle, ply, view )

		--Make sure that allowed seats use this override.
		if not Vehicle.ACE_CamOverride then return end

		if ( Vehicle.GetThirdPersonMode == nil or ply:GetViewEntity() ~= ply ) then
			-- This shouldn't ever happen.
			return
		end

		--
		-- If we're not in third person mode - then get outa here stalker
		--
		if ( not Vehicle:GetThirdPersonMode() ) then return view end

		-- Don't roll the camera
		-- view.angles.roll = 0

		local mn, mx = Vehicle:GetRenderBounds()
		local radius = ( mn - mx ):Length()
		local radius = radius + radius * Vehicle:GetCameraDistance()

		-- Trace back from the original eye position, so we don't clip through walls/objects
		local TargetOrigin = view.origin + ( view.angles:Forward() * -radius )
		local WallOffset = 4

		local tr = util.TraceHull( {
			start = view.origin,
			endpos = TargetOrigin,
			mask = CONTENTS_SOLID,
			filter = function()
				return false
			end,
			mins = Vector( -WallOffset, -WallOffset, -WallOffset ),
			maxs = Vector( WallOffset, WallOffset, WallOffset ),
		} )

		view.origin = tr.HitPos
		view.drawviewer = true

		--
		-- If the trace hit something, put the camera there.
		--
		if ( tr.Hit and not tr.StartSolid) then
			view.origin = view.origin + tr.HitNormal * WallOffset
		end

		return view

	end

	hook.Remove( "CalcVehicleView", "ACE_CalcVehicleView_Override")
	hook.Add( "CalcVehicleView", "ACE_CalcVehicleView_Override", ACE_CalcVehicleView)

	do

		net.Receive("ACE_HasGodMode", function()

			local ply = LocalPlayer()
			local Bool = net.ReadBool()

			ply.ACE_HasGodMode = Bool

		end)


	end

elseif SERVER then

	--excerpts taken from https://wiki.facepunch.com/gmod/Player:HasGodMode. Modified to use NET instead. SERVERSIDE
	-- This is a workaround to issue: https://github.com/Facepunch/garrysmod-issues/issues/2038, where clientside doesnt know if the player is in godmode or not
	-- Works with sbox_godmode convar too, then returning to its respective player god status if this command is turned off and custom godmodes are involved.
	do

		local function SendGodStatus( bool, ply )

			net.Start("ACE_HasGodMode")
				net.WriteBool(bool)

			if IsValid(ply) then
				net.Send( ply )
			else
				net.Broadcast()
			end

		end

		local PLAYER = FindMetaTable("Player")

		--To make sure we dont fuck up something else.
		PLAYER.DefaultGodEnable  = PLAYER.DefaultGodEnable  or PLAYER.GodEnable
		PLAYER.DefaultGodDisable = PLAYER.DefaultGodDisable or PLAYER.GodDisable

		function PLAYER:GodEnable()

			if GetConVar("sbox_godmode"):GetInt() <= 0 then
				SendGodStatus( true, self )
			end

			self:DefaultGodEnable()
		end

		function PLAYER:GodDisable()

			if GetConVar("sbox_godmode"):GetInt() <= 0 then
				SendGodStatus( false, self )
			end

			self:DefaultGodDisable()
		end

		cvars.RemoveChangeCallback( "sbox_godmode", "ACE_sbox_godmode" )
		cvars.AddChangeCallback("sbox_godmode", function(_, _, value )

			if tonumber(value) > 0 then

				value = true

				SendGodStatus( value, nil )
				return
			else
				for _, ply in ipairs(player.GetHumans()) do -- we dont need to send client data to bots

					SendGodStatus( ply:HasGodMode(), ply )

				end
			end

		end, "ACE_sbox_godmode" )

	end

end

-- Workaround to issue: https://github.com/Facepunch/garrysmod-issues/issues/4142. Brought from ACF3
local Hull = util.TraceHull
local Zero = Vector()

-- Available for use, just in case
if not util.LegacyTraceLine then
	util.LegacyTraceLine = util.TraceLine
end

function util.TraceLine(TraceData, ...)
	if istable(TraceData) then
		TraceData.mins = Zero
		TraceData.maxs = Zero
	end

	local TraceRes = Hull(TraceData, ...)

	-- TraceHulls don't hit player hitboxes properly, if we hit a player, retry as a regular TraceLine
	-- This fixes issues with SWEPs and toolgun traces hitting players when aiming near but not at them
	local HitEnt = TraceRes.Entity

	if istable(TraceRes) and IsValid(HitEnt) and (HitEnt:IsPlayer() or HitEnt:IsNPC()) then
		return util.LegacyTraceLine(TraceData, ...)
	end

	return TraceRes
end
