

if CLIENT then

	--Copied from garrysmod CalcVehicleView function, to allow acf ents to be included into the filter
	function ACE_CalcVehicleView( Vehicle, ply, view )

		--Make sure that allowed seats use this override.
		if not Vehicle.ACE_CamOverride then return end

		if ( Vehicle.GetThirdPersonMode == nil || ply:GetViewEntity() != ply ) then
			-- This shouldn't ever happen.
			return
		end

		--
		-- If we're not in third person mode - then get outa here stalker
		--
		if ( !Vehicle:GetThirdPersonMode() ) then return view end

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
			filter = function( e ) 
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
		if ( tr.Hit && !tr.StartSolid) then
			view.origin = view.origin + tr.HitNormal * WallOffset
		end

		return view

	end

	hook.Remove( "CalcVehicleView", "ACE_CalcVehicleView_Override")
	hook.Add( "CalcVehicleView", "ACE_CalcVehicleView_Override", ACE_CalcVehicleView)

elseif SERVER then

end

-- Workaround to issue: https://github.com/Facepunch/garrysmod-issues/issues/4142. Brought from ACF3
function util.TraceLine( tracedata )

    tracedata.mins   = vector_origin
    tracedata.maxs   = tracedata.mins

    return util.TraceHull(tracedata)
end
