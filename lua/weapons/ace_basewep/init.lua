AddCSLuaFile ("cl_init.lua")
AddCSLuaFile ("shared.lua")
 
include ("shared.lua")
 
SWEP.Weight = 10
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
	if IsValid(self:GetParent()) then
		self.Owner = self:GetParent()
		self:SetOwner(self:GetParent())
	end
	self:InitBulletData()
	self:UpdateFakeCrate()

end


function SWEP:UpdateFakeCrate(realcrate)
	if not IsValid(self.FakeCrate) then
		self.FakeCrate = ents.Create("acf_fakecrate2")
	end

	self.FakeCrate:RegisterTo(self)
	
	self.BulletData["Crate"] = self.FakeCrate:EntIndex()
	self:SetNWString( "Sound", self.Primary.Sound )
end

function SWEP:OnRemove()

if IsValid(self.Owner) then
    self.Owner:SetWalkSpeed( self.NormalPlayerWalkSpeed)
    self.Owner:SetRunSpeed( self.NormalPlayerRunSpeed)
end

	if not IsValid(self.FakeCrate) then return end
	
	local crate = self.FakeCrate
	timer.Simple(15, function() if IsValid(crate) then crate:Remove() end end)

end

local nosplode = {AP = true, APC = true, APCBC = true, APDS = true, APDSS = true, HVAP = true, HP = true, FLR = true,HEAT = true, THEAT = true}
local nopen = {HE = true, SM = true, FLR = true, HEAT = true, THEAT = true}
local heat = {HEAT = true}
local heatt = {THEAT = true}
function SWEP:DoAmmoStatDisplay()
    
    local bdata = self.BulletData
    
    local roundType = bdata.Type
	
	if bdata.Tracer and bdata.Tracer > 0 then 
		roundType = roundType .. "-T"
	end
	
	local sendInfo = string.format( "%smm %s ammo: %im/s speed",
                                   tostring(bdata.Caliber * 10),
									roundType,
									self.ThrowVel or bdata.MuzzleVel)
	
        
        if not nopen[bdata.Type] then
		local Energy = ACF_Kinetic( bdata.MuzzleVel*39.37 , bdata.ProjMass, bdata.LimitVel )
		local MaxPen = (Energy.Penetration/bdata.PenAera)*ACF.KEtoRHA
            sendInfo = sendInfo .. string.format( 	", %.1fmm pen",MaxPen)
        end
        
        if not nosplode[bdata.Type] then
            sendInfo = sendInfo .. string.format( 	", %.1fm blast",(bdata.FillerMass)^0.33*8)
            
		end
		
        if heat[bdata.Type] then
            sendInfo = sendInfo .. string.format( 	", %.1fm blast",(bdata.BoomFillerMass)^0.33*8)
		local Energy = ACF_Kinetic( bdata.SlugMV*39.37 , bdata.SlugMass, 999999 )
		local MaxPen = (Energy.Penetration/bdata.SlugPenAera)*ACF.KEtoRHA

            sendInfo = sendInfo .. string.format( 	", %.1fmm pen",MaxPen)
		end
		
        if heatt[bdata.Type] then
            sendInfo = sendInfo .. string.format( 	", %.1fm blast",(bdata.BoomFillerMass)^0.33*8)
		local Energy = ACF_Kinetic( bdata.SlugMV*39.37 , bdata.SlugMass, 999999 )
		local MaxPen = (Energy.Penetration/bdata.SlugPenAera)*ACF.KEtoRHA
           sendInfo = sendInfo .. string.format( 	", (1)%.1fmm pen",MaxPen)
		local Energy = ACF_Kinetic( bdata.SlugMV2*39.37 , bdata.SlugMass2, 999999 )
		local MaxPen = (Energy.Penetration/bdata.SlugPenAera2)*ACF.KEtoRHA
           sendInfo = sendInfo .. string.format( 	", (2)%.1fmm pen",MaxPen)
		end		
		
		
	
	self.Owner:SendLua(string.format("GAMEMODE:AddNotify(%q, \"NOTIFY_HINT\", 10)", sendInfo))
end

function SWEP:Deploy()

	self.NormalPlayerWalkSpeed = self.Owner:GetWalkSpeed()
    self.NormalPlayerRunSpeed = self.Owner:GetRunSpeed()
    
    self.Owner:SetWalkSpeed( self.NormalPlayerWalkSpeed * self.CarrySpeedMul )
    self.Owner:SetRunSpeed( self.NormalPlayerRunSpeed * self.CarrySpeedMul)
	self:Think()
	self:DoAmmoStatDisplay()
    
    if self.Zoomed then
        self:SetZoom(false)
    end
    
end

function SWEP:Holster()
	if not IsFirstTimePredicted() then return end
    self.Owner:SetWalkSpeed(self.NormalPlayerWalkSpeed)
    self.Owner:SetRunSpeed(self.NormalPlayerRunSpeed)
	return true
end

function SWEP:MuzzleEffect( MuzzlePos, MuzzleDir, realcall )

end


