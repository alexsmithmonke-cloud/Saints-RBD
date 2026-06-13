SWEP.PrintName = "Authority of Envy"
SWEP.Author = "SinningSaint"
SWEP.Purpose = "Aishiteru"
SWEP.Category = "Return By Death"
SWEP.DrawCrosshair = false 
SWEP.UseHands = true


SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

function SWEP:Initialize()
    self:SetHoldType("pistol")
end 

function SWEP:Deploy()
    self:SetNextPrimaryFire(CurTime())
end

function SWEP:PrimaryAttack()
    local owner = self:GetOwner()

    owner:EmitSound("aishiteru/aishiteru.wav", 75, 100, 1)
    owner:StripWeapon(self:GetClass())
    if not owner.SaintsEnvyFactor then
        hook.Run("SaintEnvyFactorEnabled", owner, CurTime())
    end
    owner.SaintsEnvyFactor = true
end