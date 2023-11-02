local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('kuma-busjob:server:Payment', function(route)
    local Player = QBCore.Functions.GetPlayer(source)
    Player.Functions.AddMoney('cash', Config.Route[route].Payment)
end)

lib.callback.register('kuma-busjob:server:PayFine', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    local status = false
    if Player.Functions.RemoveMoney('cash', 5000) then
        status = true
    end
    return status
end)
