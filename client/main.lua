local QBCore = exports['qb-core']:GetCoreObject()
-- blips
local hackBlip = nil
local bombBlip = nil
local heistBlip = nil

-- night vision
local nightvision = false


-- mrpd heist
local Buyer = nil
local isActive = false
local CopCount = 0
local isHacked = false
local isExploded = false
local hasKey = false
local isLooted1 = false
local isLooted2 = false

-- blackout
local BlackoutTimer = (Config.BlackoutTime*60000)





------------------------------------------------------ FUNCTIONS -------------------------------------------------------
local function HackBlip()
    hackBlip = AddBlipForCoord(470.51, -1057.03, 31.28)
    SetBlipSprite(hackBlip, 606)
    SetBlipColour(hackBlip, 66)
    SetBlipDisplay(hackBlip, 4)
    SetBlipScale(hackBlip, 0.8)
    SetBlipAsShortRange(hackBlip, false)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString('HACK')
    EndTextCommandSetBlipName(hackBlip)
    SetBlipRoute(hackBlip, true)
end

local function BombBlip()
    bombBlip = AddBlipForCoord(476.75, -1092.49, 43.08)
    SetBlipSprite(bombBlip, 486)
    SetBlipColour(bombBlip, 66)
    SetBlipDisplay(bombBlip, 4)
    SetBlipScale(bombBlip, 0.8)
    SetBlipAsShortRange(bombBlip, false)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString('BOMB')
    EndTextCommandSetBlipName(bombBlip)
    SetBlipRoute(bombBlip, true)
end

local function HeistBlip()
    heistBlip = AddBlipForCoord(453.61, -983.23, 43.69)
    SetBlipSprite(heistBlip, 134)
    SetBlipColour(heistBlip, 66)
    SetBlipDisplay(heistBlip, 4)
    SetBlipScale(heistBlip, 0.8)
    SetBlipAsShortRange(heistBlip, false)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString('MRPD HEIST')
    EndTextCommandSetBlipName(heistBlip)
    SetBlipRoute(heistBlip, true)
end

local function CallCops()
 -- your code here
end

local function OnHackDone(success)
    if success then 
        QBCore.Functions.Notify('Successfully disabled the alarm system , go to the roof to cut the power!', 'success')
        TriggerServerEvent('nxte-mrpd:server:removeitem', Config.HackItem, 1)
        RemoveBlip(hackBlip)
        BombBlip()
        TriggerServerEvent('nxte-mrpd:server:SetHack', true)
    else
        QBCore.Functions.Notify('You failed to hack the alarm system!', 'error')
        TriggerServerEvent('nxte-mrpd:server:removeitem', Config.HackItem, 1)
        TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items[Config.HackItem], 'remove')
    end
end

-- anim place the bomb
local PlantBomb = function()
    RequestAnimDict("anim@heists@ornate_bank@thermal_charge")
    RequestModel("hei_p_m_bag_var22_arm_s")
    RequestNamedPtfxAsset("scr_ornate_heist")
    while not HasAnimDictLoaded("anim@heists@ornate_bank@thermal_charge") and not HasModelLoaded("hei_p_m_bag_var22_arm_s") and not HasNamedPtfxAssetLoaded("scr_ornate_heist") do Wait(50) end
    local ped = PlayerPedId() --33
    local pos = vector4(477.31, -1083.33, 43.2, 357.5)
    SetEntityHeading(ped, pos.w)
    Wait(100)
    local rotx, roty, rotz = table.unpack(vec3(GetEntityRotation(PlayerPedId())))
    local bagscene = NetworkCreateSynchronisedScene(pos.x, pos.y, pos.z, rotx, roty, rotz, 2, false, false, 1065353216, 0, 1.3)
    local bag = CreateObject(`hei_p_m_bag_var22_arm_s`, pos.x, pos.y, pos.z,  true,  true, false)
    SetEntityCollision(bag, false, true)
    local x, y, z = table.unpack(GetEntityCoords(ped))
    local charge = CreateObject(`ch_prop_ch_explosive_01a`, x, y, z + 0.2,  true,  true, true)
    SetEntityCollision(charge, false, true)
    AttachEntityToEntity(charge, ped, GetPedBoneIndex(ped, 28422), 0, 0, 0, 0, 0, 200.0, true, true, false, true, 1, true)
    NetworkAddPedToSynchronisedScene(ped, bagscene, "anim@heists@ornate_bank@thermal_charge", "thermal_charge", 1.5, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(bag, bagscene, "anim@heists@ornate_bank@thermal_charge", "bag_thermal_charge", 4.0, -8.0, 1)
    SetPedComponentVariation(ped, 5, 0, 0, 0)
    NetworkStartSynchronisedScene(bagscene)
    Wait(5000)
    DetachEntity(charge, 1, 1)
    FreezeEntityPosition(charge, true)
    DeleteObject(bag)
    NetworkStopSynchronisedScene(bagscene)
    CreateThread(function()
        QBCore.Functions.Notify('The bomb will go off in '..Config.BombTime.. ' seconds', 'success')
        Wait((Config.BombTime * 1000)/2)
        local timer = (Config.BombTime /2)
        QBCore.Functions.Notify('The bomb will go off in '..timer.. ' seconds', 'success')
        Wait((Config.BombTime * 1000)/2)
        DeleteEntity(charge)  
        AddExplosion(477.31, -1083.33, 44, 50, 5.0, true, false, 15.0)
        if Config.SpawnPeds then
            TriggerEvent('nxte-mrpd:client:SpawnNPC', 1)
        end
        TriggerEvent('nxte-mrpd:client:setBlackout')
        QBCore.Functions.Notify('You cut the power to the city! Go to MRPD', 'success')
    end)
end


------------------------------------------------------ EVENTS -------------------------------------------------------

-- sync all info on player Load to prevent exploiting 
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    TriggerServerEvent('nxte-mrpd:server:OnPlayerLoad')
end)

--------------------
--- NIGHT VISION ---
--------------------

-- using the night vision
RegisterNetEvent('nxte-mrpd:client:nightvision', function(itemName)
    local message = nil
    if not nightvision then 
        message = 'Putting night vision on...'
    else
        message = 'Putting night vision off...'
    end

    QBCore.Functions.Progressbar("night", message, 3000, false, true, {
        disableMovement = false,
        disableCarMovement = false,
		disableMouse = false,
		disableCombat = true,
    }, {}, {}, {}, function() -- Done
        TriggerEvent("inventory:client:ItemBox", QBCore.Shared.Items['nightgoggles'], "use")    
        TriggerEvent('nxte-mrdp:client:activate-vision')
    end, function() -- Cancel
        QBCore.Functions.Notify("Cancelled putting on night vision..", "error")
    end)
end)


-- night vision animation
RegisterNetEvent('nxte-mrdp:client:activate-vision', function()
    local ped = PlayerPedId()

    if not nightvision then
		local animDict = 'mp_masks@on_foot'
		local animName = 'put_on_mask'
        RequestAnimDict(animDict)
        while not HasAnimDictLoaded(animDict) do
			Citizen.Wait(10)
		end
		TaskPlayAnim(GetPlayerPed(-1), animDict, animName, 8.0, -8.0, -1, 100, 0, false, false, false)
        Citizen.Wait(800)
        SetPedPropIndex(ped, 0, Config.NightvisionHelmetOn, 0, true)

        SetNightvision(true)
        nightvision = true

	else
		Nightvision = false
		local animDict = 'missfbi4'
		local animName = 'takeoff_mask'
		RequestAnimDict(animDict)
		while not HasAnimDictLoaded(animDict) do
			Citizen.Wait(10)
		end
		TaskPlayAnim(GetPlayerPed(-1), animDict, animName, 8.0, -8.0, -1, 80, 0, false, false, false)
        Citizen.Wait(1000)
        SetPedPropIndex(ped, 0, Config.NightVisionHelmetOff, 0, true)
        SetNightvision(false)
        nightvision = false
	end
end)

--------------------
---- MRPD HEIST ----
--------------------
RegisterNetEvent('nxte-mrpd:client:startheist', function()
    TriggerServerEvent('nxte-mrpd:server:GetCops')
    TriggerServerEvent('nxte-mrpd:server:SetActive')
    local Player = QBCore.Functions.GetPlayerData()
    local cash = Player.money.cash
    local ped = PlayerPedId()
    SetEntityCoords(ped, vector3(-787.71, -1259.38, 4.8))
    SetEntityHeading(ped, 54.89)

    TriggerEvent('animations:client:EmoteCommandStart', {"knock"})
    QBCore.Functions.Progressbar("knock", "Knocking on door...", 4000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
		disableMouse = false,
		disableCombat = true,
    }, {}, {}, {}, function() -- Done
        TriggerEvent('animations:client:EmoteCommandStart', {"c"})
        if not isActive then 
            if CopCount >= Config.MinCop then
                if cash >= Config.JobPrice then
                    HackBlip()
                    Buyer = Player.citizenid
                    TriggerServerEvent('nxte-mrpd:server:SetActive', true)
                    TriggerServerEvent('nxte-mrpd:server:removemoney', Config.JobPrice)
                    QBCore.Functions.Notify("You paid $" ..Config.JobPrice.. ' for the GPS location!', "success")
                else
                    QBCore.Functions.Notify("Am i working with an amature here ? Ofcourse i want it in cash", "error")
                end
            else
                QBCore.Functions.Notify("There is not enough police", "error")
            end
        else
            QBCore.Functions.Notify("No one is answering the door", "error")
        end

    end, function() -- Cancel
        TriggerEvent('animations:client:EmoteCommandStart', {"c"})
        QBCore.Functions.Notify("Cancelled Knocking on the door", "error")
    end)
end)


RegisterNetEvent('nxte-mrpd:client:hack', function()
    TriggerServerEvent('nxte-mrpd:server:SetActive')
    TriggerServerEvent('nxte-mrpd:server:SetHack')

    if QBCore.Functions.HasItem(Config.HackItem) then
        TriggerEvent('animations:client:EmoteCommandStart', {"uncuff"})
        QBCore.Functions.Progressbar("hack", "Connecting Device...", 4000, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {}, {}, {}, function() -- Done
            if isActive then 
                if not isHacked then
                    TriggerEvent('nxte-mrpd:anim:hack')
                else 
                    QBCore.Functions.Notify('The security system has already been hacked', 'error')
                end
            else 
                QBCore.Functions.Notify('You can not do this right now', 'error')
            end
        end, function() -- Cancel
            TriggerEvent('animations:client:EmoteCommandStart', {"c"})
            QBCore.Functions.Notify("Cancelled Connecting Device", "error")
        end)
    else 
        QBCore.Functions.Notify('You do not have the item to do this', 'error')
    end
end)

RegisterNetEvent('nxte-mrpd:anim:hack', function()
    local loc = {x,y,z,h}
    loc.x = 470.64
    loc.y = -1058.4
    loc.z = 30.3
    loc.h = 8.91

    local animDict = 'anim@heists@ornate_bank@hack'
    RequestAnimDict(animDict)
    RequestModel('hei_prop_hst_laptop')
    RequestModel('hei_p_m_bag_var22_arm_s')

    while not HasAnimDictLoaded(animDict)
        or not HasModelLoaded('hei_prop_hst_laptop')
        or not HasModelLoaded('hei_p_m_bag_var22_arm_s') do
        Wait(100)
    end

    local ped = PlayerPedId()
    local targetPosition, targetRotation = (vec3(GetEntityCoords(ped))), vec3(GetEntityRotation(ped))
    SetPedComponentVariation(ped, 5, Config.HideBagID, 1, 1)
    SetEntityHeading(ped, loc.h)
    local animPos = GetAnimInitialOffsetPosition(animDict, 'hack_enter', loc.x, loc.y, loc.z, loc.x, loc.y, loc.z, 0, 2)
    local animPos2 = GetAnimInitialOffsetPosition(animDict, 'hack_loop', loc.x, loc.y, loc.z, loc.x, loc.y, loc.z, 0, 2)
    local animPos3 = GetAnimInitialOffsetPosition(animDict, 'hack_exit', loc.x, loc.y, loc.z, loc.x, loc.y, loc.z, 0, 2)

    FreezeEntityPosition(ped, true)
    local netScene = NetworkCreateSynchronisedScene(animPos, targetRotation, 2, false, false, 1065353216, 0, 1.3)
    local bag = CreateObject(GetHashKey('hei_p_m_bag_var22_arm_s'), targetPosition, 1, 1, 0)
    local laptop = CreateObject(GetHashKey('hei_prop_hst_laptop'), targetPosition, 1, 1, 0)

    NetworkAddPedToSynchronisedScene(ped, netScene, animDict, 'hack_enter', 1.5, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(bag, netScene, animDict, 'hack_enter_bag', 4.0, -8.0, 1)
    NetworkAddEntityToSynchronisedScene(laptop, netScene, animDict, 'hack_enter_laptop', 4.0, -8.0, 1)

    local netScene2 = NetworkCreateSynchronisedScene(animPos2, targetRotation, 2, false, true, 1065353216, 0, 1.3)
    NetworkAddPedToSynchronisedScene(ped, netScene2, animDict, 'hack_loop', 1.5, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(bag, netScene2, animDict, 'hack_loop_bag', 4.0, -8.0, 1)
    NetworkAddEntityToSynchronisedScene(laptop, netScene2, animDict, 'hack_loop_laptop', 4.0, -8.0, 1)

    local netScene3 = NetworkCreateSynchronisedScene(animPos3, targetRotation, 2, false, false, 1065353216, 0, 1.3)
    NetworkAddPedToSynchronisedScene(ped, netScene3, animDict, 'hack_exit', 1.5, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(bag, netScene3, animDict, 'hack_exit_bag', 4.0, -8.0, 1)
    NetworkAddEntityToSynchronisedScene(laptop, netScene3, animDict, 'hack_exit_laptop', 4.0, -8.0, 1)

    Wait(200)
    NetworkStartSynchronisedScene(netScene)
    Wait(6300)
    NetworkStartSynchronisedScene(netScene2)
    Wait(2000)

    exports['hacking']:OpenHackingGame(Config.HackTime, Config.HackSquares, Config.HackRepeat, function(success)
        NetworkStartSynchronisedScene(netScene3)
        NetworkStopSynchronisedScene(netScene3)
        DeleteObject(bag)
        SetPedComponentVariation(ped, 5, Config.BagUseID, 0, 1)
        DeleteObject(laptop)
        FreezeEntityPosition(ped, false)
        OnHackDone(success)
    end)
end)


RegisterNetEvent('nxte-mrpd:client:bomb', function()
    TriggerServerEvent('nxte-mrpd:server:SetActive')
    TriggerServerEvent('nxte-mrpd:server:SetHack')
    TriggerServerEvent('nxte-mrpd:server:SetBomb')
    QBCore.Functions.Progressbar("hack", "Preparing Bomb...", 3000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- Done
        if isActive then 
            if isHacked then 
                if not isExploded then
                    if QBCore.Functions.HasItem(Config.BombItem) then
                        exports["memorygame"]:thermiteminigame(Config.BombBlocks,Config.BombBlocksFail, Config.BombShowTime, Config.BombHackTime,
                        function() -- success
                            -- trigger bomb animation
                            TriggerServerEvent('nxte-mrpd:server:SetBomb', true)
                            HeistBlip()
			    RemoveBlip(bombBlip)
			    TriggerServerEvent('nxte-mrpd:server:removeitem', Config.BombItem, 1)
                            PlantBomb()
                        end,
                        function() -- failure
                            TriggerServerEvent('nxte-mrpd:server:removeitem', Config.BombItem, 1)
                            QBCore.Functions.Notify('You failed to cut the power!', 'success')
    
                        end)
                    else 
                        QBCore.Functions.Notify('You do not have the item to do this', 'error')
                    end
                else 
                    QBCore.Functions.Notify('This genrator has already exploded', 'error')
                end
            else 
                QBCore.Functions.Notify('The security system is still active', 'error')
            end              
        else 
            QBCore.Functions.Notify('You can not do this now', 'error')
        end
    end, function() -- Cancel
        QBCore.Functions.Notify("Cancelled preparing the bomb", "error")
    end)
end)

RegisterNetEvent('nxte-mrpd:client:setBlackout', function()
    TriggerServerEvent("qb-weathersync:server:toggleBlackout")
    Citizen.Wait(BlackoutTimer)
    TriggerServerEvent("qb-weathersync:server:toggleBlackout")
end)

-- grab key
RegisterNetEvent('nxte-mrpd:client:grabkey', function()
    TriggerServerEvent('nxte-mrpd:server:SetActive')
    TriggerServerEvent('nxte-mrpd:server:SetKey')
    QBCore.Functions.Progressbar("key", "Searching Pile of papers...", 3000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- Done
        if isActive then
            if isExploded then
                if not hasKey then
                    TriggerServerEvent('nxte-mrpd:server:SetKey', true)
		    TriggerServerEvent('nxte-mrpd:server:additem', 'armorykey', 1)
                    QBCore.Functions.Notify('You found a MRPD Armory key', 'success')
                else 
                    QBCore.Functions.Notify('Someone already grabbed the key!', 'error')
                end
            else 
                QBCore.Functions.Notify('The power is still on', 'error')
            end          
        else 
            QBCore.Functions.Notify('You can not do this now', 'error')
        end
    end, function() -- Cancel
        QBCore.Functions.Notify("Cancelled searching the pile of papers", "error")
    end)
end)


RegisterNetEvent('nxte-mrpd:client:loot1', function()
    TriggerServerEvent('nxte-mrpd:server:SetActive')
    TriggerServerEvent('nxte-mrpd:server:SetLoot1')
    if isActive then
        if hasKey then
            QBCore.Functions.Progressbar("key", "Searching Locker...", 3000, false, true, {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            }, {}, {}, {}, function() -- Done
                if not isLooted2 then
                    TriggerServerEvent('nxte-mrpd:server:SetLoot1', true)
                    local amount = math.random(Config.Loot1MinAmount, Config.Loot1MaxAmount)
		    TriggerServerEvent('nxte-mrpd:server:additem', Config.Loot1Item, amount)
                else 
                    QBCore.Functions.Notify('Someone already grabbed the items in the locker', 'error')
                end
            end, function() -- Cancel
                QBCore.Functions.Notify("Cancelled searching the locker", "error")
            end)
        else
            QBCore.Functions.Notify('You dont have the access card to open the locker','error')
        end
    else 
        QBCore.Functions.Notify('You can not do this right now','error')
    end
end)

RegisterNetEvent('nxte-mrpd:client:loot2', function()
    TriggerServerEvent('nxte-mrpd:server:SetActive')
    TriggerServerEvent('nxte-mrpd:server:SetLoot2')
    if isActive then
        if hasKey then
            QBCore.Functions.Progressbar("key", "Searching Locker...", 3000, false, true, {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            }, {}, {}, {}, function() -- Done
                if not isLooted2 then
                    TriggerServerEvent('nxte-mrpd:server:SetLoot2', true)
                    local amount = math.random(Config.Loot2MinAmount, Config.Loot2MaxAmount)
		    TriggerServerEvent('nxte-mrpd:server:additem', Config.Loot2Item, amount)
                else 
                    QBCore.Functions.Notify('Someone already grabbed the items in the locker', 'error')
                end
            end, function() -- Cancel
                QBCore.Functions.Notify("Cancelled searching the locker", "error")
            end)
        else
            QBCore.Functions.Notify('You dont have the access card to open the locker','error')
        end
    else 
        QBCore.Functions.Notify('You can not do this right now','error')
    end
end)

-----------
--- NPC ---
-----------
-- set NPC data
RegisterNetEvent('nxte-mrpd:client:SpawnNPC', function(position)
    QBCore.Functions.TriggerCallback('nxte-mrpd:server:SpawnNPC', function(netIds, position)
        Wait(1000)
        local ped = PlayerPedId()
        for i=1, #netIds, 1 do
            local npc = NetworkGetEntityFromNetworkId(netIds[i])
            SetPedDropsWeaponsWhenDead(npc, false)
            GiveWeaponToPed(npc, Config.PedGun, 250, false, true)
            SetPedMaxHealth(npc, 300)
            SetPedArmour(npc, 200)
            SetCanAttackFriendly(npc, true, false)
            TaskCombatPed(npc, ped, 0, 16)
            SetPedCombatAttributes(npc, 46, true)
            SetPedCombatAttributes(npc, 0, false)
            SetPedCombatAbility(npc, 100)
            SetPedAsCop(npc, true)
            SetPedRelationshipGroupHash(npc, `HATES_PLAYER`)
            SetPedAccuracy(npc, 60)
            SetPedFleeAttributes(npc, 0, 0)
            SetPedKeepTask(npc, true)
            SetBlockingOfNonTemporaryEvents(npc, true)
        end
    end, position)
end)


---------------------
---- SERVER SYNC ----
---------------------

-- get active cops
RegisterNetEvent('nxte-mrpd:client:GetCops', function(amount)
    CopCount = amount
end)

-- get active status
RegisterNetEvent('nxte-mrpd:client:SetActive', function(status)
    isActive = status
end)

RegisterNetEvent('nxte-mrpd:client:SetHack', function(status)
    isHacked = status
end)

RegisterNetEvent('nxte-mrpd:client:SetBomb', function(status)
    isExploded = status
end)

RegisterNetEvent('nxte-mrpd:client:SetKey', function(status)
    hasKey = status
end)

RegisterNetEvent('nxte-mrpd:client:SetLoot1', function(status)
    isLooted1 = status
end)

RegisterNetEvent('nxte-mrpd:client:SetLoot2', function(status)
    isLooted2 = status
end)
-------------------------------------------------------- Threads ----------------------------------------------------

-- reset heist 
Citizen.CreateThread(function()
    while true do 
        Citizen.Wait(1)
        if isLooted1 and isLooted2 then
            RemoveBlip(heistBlip)
            Citizen.Wait(Config.TimeOut*60000)
            TriggerServerEvent('nxte-mrpd:server:ResetMission')
	    RemoveBlip(heistBlip)		
        end
    end
end)

-- reset heist on player death
Citizen.CreateThread(function()
    while true do
        if isActive then
            local Player = QBCore.Functions.GetPlayerData()
            local Playerid = Player.citizenid
            if Playerid == Buyer then
                if Player.metadata["inlaststand"] or Player.metadata["isdead"] then
                    QBCore.Functions.Notify('Mission Failed', 'error')
                    TriggerServerEvent('nxte-mrpd:server:ResetMission')
                    Citizen.Wait(2000)
		    RemoveBlip(heistBlip)
                    Buyer = nil
                end
            end
        end
        Citizen.Wait(5000)
    end
end)




