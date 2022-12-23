local QBCore = exports['qb-core']:GetCoreObject()

local isActive = false
local CopCount = 0
local isHacked = false
local isExploded = false
local hasKey = false
local isLooted1 = false
local isLooted2 = false

--------------------
--- NIGHT VISION ---
--------------------
QBCore.Functions.CreateUseableItem("nightgoggles", function(source, item)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    TriggerClientEvent('nxte-mrpd:client:nightvision', src)
end)

RegisterNetEvent('nxte-mrpd:server:removeitem',function(item , amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.RemoveItem(item, amount)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], "remove")
end)

RegisterNetEvent('nxte-mrpd:server:additem',function(item , amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.AddItem(item, amount)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], "add")
end)

--------------------
---- MRPD HEIST ----
--------------------
-- remove money
RegisterNetEvent('nxte-mrpd:server:removemoney', function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.RemoveMoney('cash', tonumber(amount))
end)

-- getting active cops
RegisterNetEvent('nxte-mrpd:server:GetCops', function()
	local amount = 0
    for k, v in pairs(QBCore.Functions.GetQBPlayers()) do
        if v.PlayerData.job.name == "police" and v.PlayerData.job.onduty then
            amount = amount + 1
        end
    end
    CopCount = amount
    TriggerClientEvent('nxte-mrpd:client:GetCops', -1, amount)
end)

-- changing isactive status
RegisterNetEvent('nxte-mrpd:server:SetActive', function(status)
    if status ~= nil then 
        isActive = status 
        TriggerClientEvent('nxte-mrpd:client:SetActive', -1, status)
    else 
        TriggerClientEvent('nxte-mrpd:client:SetActive', -1, isActive)
    end 
end)

-- changing ishacked status
RegisterNetEvent('nxte-mrpd:server:SetHack', function(status)
    if status ~= nil then 
        isHacked = status 
        TriggerClientEvent('nxte-mrpd:client:SetHack', -1, status)
    else 
        TriggerClientEvent('nxte-mrpd:client:SetHack', -1, isHacked)
    end 
end)

-- changing bomb status
RegisterNetEvent('nxte-mrpd:server:SetBomb', function(status)
    if status ~= nil then 
        isExploded = status 
        TriggerClientEvent('nxte-mrpd:client:SetBomb', -1, status)
    else 
        TriggerClientEvent('nxte-mrpd:client:SetBomb', -1, isExploded)
    end 
end)

-- changing key status
RegisterNetEvent('nxte-mrpd:server:SetKey', function(status)
    if status ~= nil then 
        hasKey = status 
        TriggerClientEvent('nxte-mrpd:client:SetKey', -1, status)
    else 
        TriggerClientEvent('nxte-mrpd:client:SetKey', -1, hasKey)
    end 
end)

-- changing loot 1
RegisterNetEvent('nxte-mrpd:server:SetLoot1', function(status)
    if status ~= nil then 
        isLooted1 = status 
        TriggerClientEvent('nxte-mrpd:client:SetLoot1', -1, status)
    else 
        TriggerClientEvent('nxte-mrpd:client:SetLoot1', -1, isLooted1)
    end 
end)

-- changing loot 2
RegisterNetEvent('nxte-mrpd:server:SetLoot2', function(status)
    if status ~= nil then 
        isLooted2 = status 
        TriggerClientEvent('nxte-mrpd:client:SetLoot2', -1, status)
    else 
        TriggerClientEvent('nxte-mrpd:client:SetLoot2', -1, isLooted2)
    end 
end)

--- RESET MISSION 
RegisterNetEvent('nxte-mrpd:server:ResetMission', function(status)
    TriggerEvent('nxte-mrpd:server:SetActive', false) 
    TriggerEvent('nxte-mrpd:server:SetHack', false) 
    TriggerEvent('nxte-mrpd:server:SetBomb', false) 
    TriggerEvent('nxte-mrpd:server:SetPower', false) 
    TriggerEvent('nxte-mrpd:server:SetKey', false) 
    TriggerEvent('nxte-mrpd:server:SetLoot1', false) 
    TriggerEvent('nxte-mrpd:server:SetLoot2', false) 
end)

--- ON PLAYER LOAD
RegisterNetEvent('nxte-mrpd:server:OnPlayerLoad', function(status)
    TriggerEvent('nxte-mrpd:server:SetActive') 
    TriggerEvent('nxte-mrpd:server:SetHack') 
    TriggerEvent('nxte-mrpd:server:SetBomb') 
    TriggerEvent('nxte-mrpd:server:SetPower') 
    TriggerEvent('nxte-mrpd:server:SetKey') 
    TriggerEvent('nxte-mrpd:server:SetLoot1') 
    TriggerEvent('nxte-mrpd:server:SetLoot2') 
end)


-- NPC 
local peds = { 
    `s_m_m_snowcop_01`,
    `s_m_y_cop_01`,
    `s_m_y_hwaycop_01`,
    `s_m_y_ranger_01`,
    `s_m_y_sheriff_01`,
}

local getRandomNPC = function()
    return peds[math.random(#peds)]
end

QBCore.Functions.CreateCallback('nxte-mrpd:server:SpawnNPC', function(source, cb, loc)
    local netIds = {}
    local netId
    local npc
    for i=1, #Config.Shooters['soldiers'].locations[loc].peds, 1 do
        npc = CreatePed(30, getRandomNPC(), Config.Shooters['soldiers'].locations[loc].peds[i], true, false)
        while not DoesEntityExist(npc) do Wait(10) end
        netId = NetworkGetNetworkIdFromEntity(npc)
        netIds[#netIds+1] = netId
    end
    cb(netIds)
end)

