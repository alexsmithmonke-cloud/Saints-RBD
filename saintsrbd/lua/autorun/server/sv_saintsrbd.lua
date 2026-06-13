AddCSLuaFile()

function SavingDataForRestore(ply)
    local allply = player.GetAll()
    SaintsRBDallentBeforeRBD = ents.GetAll()
    --All Player Info Saving
    for _, currentplayer in pairs(allply) do
        currentplayer.PosBeforeRBD = currentplayer:GetPos()
        currentplayer.AngsBeforeRBD = currentplayer:EyeAngles()
        currentplayer.HealthBeforeRBD = currentplayer:Health()

        currentplayer.WeaponsBeforeRBD = {}
        for _, wep in pairs(currentplayer:GetWeapons()) do
            if IsValid(wep) then
                table.insert(currentplayer.WeaponsBeforeRBD, wep:GetClass())
            end
        end
        local activeWep = currentplayer:GetActiveWeapon()
        currentplayer.ActiveWeaponBeforeRBD = activeWep:GetClass()
        currentplayer.AmmoBeforeRBD = currentplayer:GetAmmo()
    end
    --All Player Info Saving

    --All Entity Info Saving
        
    Saintsallentdata = {}
    for _, currentent in pairs(SaintsRBDallentBeforeRBD) do
        Saintsallentdata[currentent] = {
            PosBeforeRBD = currentent:GetPos(),
            AngsBeforeRBD = currentent:GetAngles(),
            HealthBeforeRBD = currentent:Health(),
            ModelBeforeRBD = currentent:GetModel(),
            ClassBeforeRBD = currentent:GetClass(),
        }
        local phys = currentent:GetPhysicsObject()
        if IsValid(phys) then
            Saintsallentdata[currentent].FreezeStatusBeforeRBD = phys:IsMotionEnabled()
        end
        if currentent:IsNPC() then
            local wep = currentent:GetActiveWeapon()
            Saintsallentdata[currentent].WeaponBeforeRBD = wep:GetClass()
        end
    end
    --All Entity Info Saving
    local numberToBeUsedForNextActivition = math.random(60, 60 * 10)
    ply:SetNW2Int("TimersRelatingToEnvyFactor", numberToBeUsedForNextActivition)
end

function EnvyFactor(ply, FactorAttainTime)
    local id1 = ply:EntIndex()
    local id2 = ply:GetName()
    local numberToBeUsedForNextActivition = math.random(60, 60 * 10)
    ply:SetNW2Int("TimersRelatingToEnvyFactor", numberToBeUsedForNextActivition)
    local nameTimerToSaveEverything = id1.."TimerToSaveEverything"..id2
    timer.Remove(nameTimerToSaveEverything)
    SavingDataForRestore(ply)
    timer.Create(nameTimerToSaveEverything, ply:GetNW2Int("TimersRelatingToEnvyFactor"), 0, function()
        SavingDataForRestore()
    end)
end
function RBD(ply)
    local allply = player.GetAll()
    local allcurrentents = ents.GetAll()
    --All Player Info Restore
    for _, currentplayer in pairs(allply) do
        SuppressHostEvents(currentplayer)
        currentplayer:SetNW2Bool("RBD_IsSilent", true)
        currentplayer:SetPos(currentplayer.PosBeforeRBD)
        currentplayer:SetEyeAngles(currentplayer.AngsBeforeRBD)
        currentplayer:SetHealth(currentplayer.HealthBeforeRBD)
        currentplayer:StripWeapons()
        if currentplayer.WeaponsBeforeRBD then
            for _, weaponClass in pairs(currentplayer.WeaponsBeforeRBD) do
                currentplayer:Give(weaponClass)
            end
        end
        currentplayer:SelectWeapon(currentplayer.ActiveWeaponBeforeRBD)
        currentplayer:RemoveAllAmmo()
        for ammoID, ammoCount in pairs(currentplayer.AmmoBeforeRBD) do
            currentplayer:GiveAmmo(ammoCount, ammoID,true)
        end
        currentplayer:SetNW2Bool("RBD_IsSilent", false)
        SuppressHostEvents(nil)
        currentplayer:ScreenFade(SCREENFADE.IN, Color(0,0,0), 1, 1)
        currentplayer:EmitSound("rbd/re-zero-return-by-death.wav",150, 100, 1)
    end
    --All Player Info Restore

    --All entity/prop/NPC Info Restore
    for _, ent in pairs(allcurrentents) do
        if not ent:IsPlayer() and ent:IsNPC() or ent:GetClass() == "prop_physics" then
            ent:Remove()
        end
    end
    for _, currentent in pairs(SaintsRBDallentBeforeRBD) do
        if currentent:IsWorld() or currentent:IsPlayer() then continue end
        local entstring = tostring(currentent)
        if entstring == "Weapon [NULL]" then continue end
        if currentent == NULL or currentent:IsNPC() then
            if not Saintsallentdata[currentent].ModelBeforeRBD then continue end
            SpawninginRBDStuff(currentent)
            continue
        elseif currentent:GetClass() == "prop_physics" then
            SpawninginRBDStuff(currentent)
            continue
        end
    end
    --All entity/prop/NPC Info Restore
    timer.Simple(0.01, function() 
        EnvyFactor(ply, CurTime()) 
    end)
end

function SpawninginRBDStuff(currentent)
    local currententdata = Saintsallentdata[currentent]
    local classchosenforent
    if currentent == NULL then
        classchosenforent = "prop_physics"
    elseif currentent:IsNPC() then
        classchosenforent = currententdata.ClassBeforeRBD
    elseif currentent:GetClass() == "prop_physics" then
        classchosenforent = "prop_physics"
    end
    local remakingent = ents.Create(classchosenforent)
    remakingent:SetPos(currententdata.PosBeforeRBD)
    remakingent:SetAngles(currententdata.AngsBeforeRBD)
    remakingent:SetHealth(currententdata.HealthBeforeRBD)
    remakingent:SetModel(currententdata.ModelBeforeRBD)
    if currentent:IsNPC() then
        remakingent:Give(currententdata.WeaponBeforeRBD)
    end
    remakingent:Spawn()
    local phys = remakingent:GetPhysicsObject()
    if IsValid(phys) then
        phys:EnableMotion(currententdata.FreezeStatusBeforeRBD)
    end
end

hook.Add("SaintEnvyFactorEnabled", "EnvyFactorEnabled", function(ply,FactorAttainTime)
    ply.SaintsEnvyFactor = true
    EnvyFactor(ply, FactorAttainTime)
end)

hook.Add("EntityTakeDamage", "ToCheckIfRbdShouldBeActivited", function(ply,dmginfo)

    if IsValid(ply) and ply:Health() - dmginfo:GetDamage() < 1 and ply.SaintsEnvyFactor then
        dmginfo:SetDamage(0)
        timer.Simple(0.2, function()

            RBD(ply)
        
        end)
    end

end)

hook.Add("PlayerDeath", "ToResetFactors", function(ply)
    concommand.Run(ply, "Saint_Reset_Factors")
end)


