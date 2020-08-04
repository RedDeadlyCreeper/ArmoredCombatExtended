AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")


function ENT:Initialize()

	self:SetModel( "models/jaanus/wiretool/wiretool_range.mdl" )
	self:SetMoveType(MOVETYPE_VPHYSICS);
	self:PhysicsInit(SOLID_VPHYSICS);
	self:SetUseType(SIMPLE_USE);
	self:SetSolid(SOLID_VPHYSICS);
	local phys = self:GetPhysicsObject()
	phys:SetMass(0.5) --4.1 kg mine, round down.
	
	self.TimeVar = 1
	self.MineState = 0
	self.phys = phys
	self.LastTime = 0
	if ( IsValid( phys ) ) then phys:Wake() end
end


function ENT:Think()

		self.TimeVar = self.TimeVar + 1

			if self.TimeVar >= 4 then
				self.TimeVar = 0

				if self.MineState == 0 then --Mine not buried in ground. Mine will look for ground.

					local groundRanger = util.TraceLine( {
						start = self:GetPos() + Vector(0,0,20),
						endpos = self:GetPos() + Vector(0,0,-50),
						collisiongroup = COLLISION_GROUP_WORLD,
						filter = function( ent ) if ( ent:GetClass() == "prop_physics" ) then return true end end
					} )	
					
					if groundRanger.Hit and groundRanger.HitWorld then
					self:SetPos(groundRanger.HitPos+Vector(0,0,-1.7))
					self:SetAngles(groundRanger.HitNormal:Angle()+Angle(90,0,0))
					self.MineState = 1
					self.phys:EnableMotion(false)
					end
					--print(groundRanger.Hit)
					
				elseif self.MineState == 1 then --Mine activated and searching for enemy

					local triggerRanger = util.TraceHull( {
						start = self:GetPos() + Vector(0,0,52),
						endpos = self:GetPos() + Vector(0,0,87.1),
						ignoreworld  = true,
						mins = Vector( -60, -60, -20 ),
						maxs = Vector( 60, 60, 20 ),
						mask = MASK_SHOT_HULL
					} )

					if triggerRanger.Hit then
						self:SetPos(self:GetPos() + self:GetUp()*10)
						ACF_HE( self:GetPos() , Vector(0,0,1) , 2 , 25 , self:GetOwner(), nil, self) --0.5 is standard antipersonal mine

						local Flash = EffectData()
						Flash:SetOrigin( self:GetPos() + self:GetUp()*10 )
						Flash:SetNormal( Vector(0,0,-1) )
						Flash:SetRadius( 2 )
						util.Effect( "ACF_Scaled_Explosion", Flash )
				
						self:Remove()
					end
				end

else


end

end


function ENT:OnRemove()
end









