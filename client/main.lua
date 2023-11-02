-- Variables
local QBCore = exports['qb-core']:GetCoreObject()
local route = 1
local max = nil
local busBlip = nil
local TextUI = false
print("tes")

local RouteData = {
    Blip = nil,
    coord = nil,
    LastNpc = nil,
    box = nil,
    Active = nil,
    route = nil,
}

local BusData = {
    Active = false,
    vehicle = nil,
}

-- Functions

local function updateBlip()
    local PlayerData = QBCore.Functions.GetPlayerData()
    if PlayerData.job.name == "bus" then
        busBlip = AddBlipForCoord(Config.Location)
        SetBlipSprite(busBlip, 513)
        SetBlipDisplay(busBlip, 4)
        SetBlipScale(busBlip, 0.6)
        SetBlipAsShortRange(busBlip, true)
        SetBlipColour(busBlip, 49)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(Lang:t('info.bus_depot'))
        EndTextCommandSetBlipName(busBlip)
    elseif busBlip ~= nil then
        RemoveBlip(busBlip)
    end
end

local function nextStop()
    if route <= (max - 1) then
        route = route + 1
    else
        route = 100
    end
    return route
end

function SpawnBus(rute)
    BusData.active = true
    RouteData.route = rute
    max = #Config.Route[rute].Location
    QBCore.Functions.TriggerCallback('QBCore:Server:SpawnVehicle', function(netId)
        local veh = NetToVeh(netId)
        BusData.vehicle = veh
        SetVehicleNumberPlateText(veh, Lang:t('info.bus_plate') .. tostring(math.random(1000, 9999)))
        exports[Config.Fuel]:SetFuel(veh, 100.0)
        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
        TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(veh))
        SetVehicleEngineOn(veh, true, true)
    end, 'bus', Config.Route[rute].TakeLocation, true)
    Wait(1000)
    TriggerEvent('kuma-busjob:client:DoBusNpc')
    -- end
end

-- Events
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        updateBlip()
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    updateBlip()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    PlayerData = {}
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerData.job = JobInfo
    updateBlip()
end)

RegisterNetEvent('kuma-busjob:client:DoBusNpc', function()
    Wait(1000)
    if RouteData.Blip ~= nil then
        RemoveBlip(RouteData.Blip)
    end
    RouteData.coord = Config.Route[RouteData.route].Location[route]
    TextUI = true
    RouteData.Blip = AddBlipForCoord(RouteData.coord.x, RouteData.coord.y, RouteData.coord.z)
    SetBlipColour(RouteData.Blip, 3)
    SetBlipRoute(RouteData.Blip, true)
    SetBlipRouteColour(RouteData.Blip, 3)
    RouteData.LastNpc = route
    RouteData.Active = true
    RouteData.box = lib.zones.box({
        coords = RouteData.coord,
        size = vec3(10, 10, 10),
        rotation = 45,
        debug = false,
        inside = function()
            if IsControlJustPressed(0, 38) then
                local veh = GetVehiclePedIsIn(cache.ped, false)
                if veh then
                    if veh == BusData.vehicle then
                        SetEntityVelocity(veh, 0.0, 0.0, 0.0)
                        SetVehicleDoorOpen(veh, 1, false, false)
                        SetVehicleDoorOpen(veh, 0, false, false)
                        if lib.progressCircle({
                                duration = 5000,
                                position = 'bottom',
                                label = 'Menunggu Penumpang',
                                useWhileDead = false,
                                canCancel = false,
                                disable = {
                                    car = true,
                                },
                                anim = {},
                                prop = {},
                            }) then
                            Notify(Locale['bus_title'], Locale['bus_goto_nextstop'], 'success', 5000)
                            if RouteData.NpcBlip ~= nil then
                                RemoveBlip(RouteData.NpcBlip)
                            end
                            if nextStop() ~= 100 then
                                TriggerEvent('kuma-busjob:client:DoBusNpc')
                            else
                                TriggerEvent('kuma-busjob:client:GoBack')
                            end
                            SetVehicleDoorShut(veh, 1, false)
                            SetVehicleDoorShut(veh, 0, false)
                            RouteData.NpcTaken = true
                            RouteData.box:remove()
                            RouteData.box = nil
                            RouteData.coord = nil
                        end
                    else
                        Notify(Locale['bus_title'], Locale['bus_error_not_self_bus'], 'error', 5000)
                    end
                else
                    Notify(Locale['bus_title'], Locale['bus_error_not_in_bus'], 'error', 5000)
                end
            end
        end,
        onEnter = function()
            Notify(Locale['bus_title'], Locale['bus_take_passenger'], 'success', 5000)
        end
    })
end)

CreateThread(function()
    while true do
        if TextUI then
            if not BusData.active then
                TextUI = false
                lib.hideTextUI()
                return
            end
            RouteData.coord = route ~= 'back'
                and Config.Route[RouteData.route].Location[route] or Config.Route[RouteData.route].Backlocation
            local streetName, crossingRoad = GetStreetNameAtCoord(RouteData.coord.x, RouteData.coord.y, RouteData.coord
                .z)
            local message = ''
            if route == 100 then
                message = string.format(Locale['bus_textUI_information_back'], GetStreetNameFromHashKey(streetName),
                    GetStreetNameFromHashKey(crossingRoad))
            else
                message = string.format(Locale['bus_textUI_information_next'], GetStreetNameFromHashKey(streetName),
                    GetStreetNameFromHashKey(crossingRoad), max + 1 - route)
            end
            lib.showTextUI(
                message, {
                    position = "left-center",
                    icon = 'bus',
                    style = {
                        borderRadius = 4,
                        backgroundColor = 'black',
                        color = 'white'
                    }
                })
            Wait(1000)
        else
            Wait(5000)
        end
    end
end)

RegisterNetEvent('kuma-busjob:client:GoBack', function()
    Wait(1000)
    if RouteData.Blip ~= nil then
        RemoveBlip(RouteData.Blip)
    end
    Notify(Locale['bus_title'], Locale['bus_goto_nextstop'], 'success', 5000)
    RouteData.coord = Config.Route[RouteData.route].Backlocation
    RouteData.Blip = AddBlipForCoord(RouteData.coord.x, RouteData.coord.y, RouteData.coord.z)
    SetBlipColour(RouteData.Blip, 3)
    SetBlipRoute(RouteData.Blip, true)
    SetBlipRouteColour(RouteData.Blip, 3)
    RouteData.LastNpc = route
    RouteData.Active = true
    RouteData.box = lib.zones.box({
        coords = RouteData.coord,
        size = vec3(10, 10, 10),
        rotation = 45,
        debug = false,
        inside = function()
            if IsControlJustPressed(0, 38) then
                local veh = GetVehiclePedIsIn(cache.ped, false)
                if veh then
                    if veh == BusData.vehicle then
                        DeleteVehicle(GetVehiclePedIsIn(cache.ped, false))
                        TriggerServerEvent('kuma-busjob:server:Payment', RouteData.route)
                        RouteData.box:remove()
                        ResetBus()
                    else
                        Notify(Locale['bus_title'], Locale['bus_error_not_self_bus'], 'error', 5000)
                    end
                else
                    Notify(Locale['bus_title'], Locale['bus_error_not_in_bus'], 'error', 5000)
                end
            end
        end,
        onEnter = function()
            Notify(Locale['bus_title'], Locale['bus_take_passenger'], 'success', 5000)
        end
    })
end)

function ResetBus()
    BusData = {}
    RouteData = {
        Blip = nil,
        coord = nil,
        LastNpc = nil,
        box = nil,
        Active = nil,
        route = nil,
    }
    route = 1
    max = nil
    busBlip = nil
end

CreateThread(function()
    for k, v in pairs(Config.Route) do
        local box = lib.zones.box({
            coords = v.TakeLocation,
            size = vec3(10, 10, 10),
            rotation = 45,
            debug = false,
            inside = function()
                if IsControlJustPressed(1, 206) then
                    BusMenu(k)
                end
            end,
            onEnter = function()
                local message = string.format(Locale['bus_take_route'], v.Label)
                local PlayerData = QBCore.Functions.GetPlayerData()
                if BusData.active then
                    if GetVehiclePedIsIn(cache.ped, false) == BusData.vehicle then
                        message = Locale['bus_return']
                    else
                        message = Locale['bus_return_fine']
                    end
                end
                if PlayerData.job.name == 'bus' then
                    if not TextUI then
                        lib.showTextUI(message, {
                            position = "left-center",
                            icon = 'bus',
                            style = {
                                borderRadius = 0,
                                backgroundColor = '#48BB78',
                                color = 'white'
                            }
                        })
                    else
                        Notify(Locale['bus_title'], message, 'success', 5000)
                    end
                end
            end,
            onExit = function()
                if not TextUI then
                    lib.hideTextUI()
                end
            end
        })
    end
end)

function BusMenu(route)
    local PlayerData = QBCore.Functions.GetPlayerData()
    if PlayerData.job.name == 'bus' then
        if not BusData.active then
            local coord = Config.Route[route].TakeLocation
            if not IsPedInAnyVehicle(cache.ped, false) then
                if not IsAnyVehicleNearPoint(coord.x, coord.y, coord.z, 2.5) then
                    SpawnBus(route)
                else
                    Notify(Locale['bus_title'], Locale['bus_parking_full'], 'error', 5000)
                end
            else
                Notify(Locale['bus_title'], Locale['bus_get_out_from_vehicle'], 'error', 5000)
            end
        else
            if GetVehiclePedIsIn(cache.ped, false) == BusData.vehicle then
                DeleteVehicle(GetVehiclePedIsIn(cache.ped, false))
                RouteData.box:remove()
                ResetBus()
            else
                local alert = lib.alertDialog({
                    header = 'Agent Bus',
                    content =
                    'Informasi  \n Kamu akan membayar denda karena bus mu hilang !  \n  Setelah membayar, kamu bisa mengambil bus lagi',
                    centered = true,
                    cancel = true
                })
                if alert == 'confirm' then
                    local status = lib.callback.await('kuma:server:PayFine')
                    if status then
                        RouteData.box:remove()
                        ResetBus()
                        Notify(Locale['bus_title'], Locale['bus_pay_fine_success'], 'success', 5000)
                    else
                        Notify(Locale['bus_title'], Locale['bus_pay_fine_error'], 'error', 5000)
                    end
                end
            end
        end
    else
        Notify(Locale['bus_title'], Locale['bus_not_bus_job'], 'error', 5000)
    end
end
