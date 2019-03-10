print("radar type support loaded")


ACFM.RadarBehaviour = ACFM.RadarBehaviour or {}
ACFM.DefaultRadarSound = ACFM.DefaultRadarSound or "buttons/button16.wav"

ACFM.RadarBehaviour["DIR-AM"] = 
{
	GetDetectedEnts = function(self)
		return ACFM_GetMissilesInCone(self:GetPos(), self:GetForward(), self.ConeDegs)
	end
}


ACFM.RadarBehaviour["OMNI-AM"] = 
{
	GetDetectedEnts = function(self)
		return ACFM_GetMissilesInSphere(self:GetPos(), self.Range)
	end
}