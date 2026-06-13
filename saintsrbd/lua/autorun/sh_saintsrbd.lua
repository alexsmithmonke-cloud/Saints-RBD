AddCSLuaFile()

concommand.Add("Saint_Reset_Factors", function(ply)

    if IsValid(ply) then
        local id1 = ply:EntIndex()
        local id2 = ply:GetName()
        local nameTimerToSaveEverything = id1.."TimerToSaveEverything"..id2
        ply.FactorTimerEnabled = false
        ply.SaintsEnvyFactor = false
        timer.Remove(nameTimerToSaveEverything)     
    end

end)