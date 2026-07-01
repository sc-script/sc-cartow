local attachedVehicleByFlatbed = {}
local attachedFlatbedByVehicle = {}
local targetAdded = {}
local progressActive = false

local function notify(message, type)
    Config.Notify(message, type)
end

local function isFlatbedEntity(entity)
    if not entity or entity == 0 or not DoesEntityExist(entity) then
        return false
    end

    if GetEntityType(entity) ~= 2 then
        return false
    end

    local modelHash = GetEntityModel(entity)
    local modelName = string.lower(GetDisplayNameFromVehicleModel(modelHash) or '')

    for _, name in ipairs(Config.FlatbedModels) do
        if string.find(modelName, string.lower(name), 1, true) then
            return true
        end
    end

    return false
end

local function addTargetToFlatbed(entity)
    if not DoesEntityExist(entity) or targetAdded[entity] then
        return
    end

    exports.ox_target:addLocalEntity(entity, {
        {
            label = 'Качи кола',
            icon = 'fa-solid fa-truck-ramp-box',
            distance = 2.5,
            canInteract = function(_, _, _, _)
                return not attachedVehicleByFlatbed[entity]
            end,
            onSelect = function(data)
                TriggerEvent('sc-cartow:loadNearestVehicle', data.entity)
            end,
        },
        {
            label = 'Свали кола',
            icon = 'fa-solid fa-truck-ramp-box',
            distance = 2.5,
            canInteract = function(_, _, _, _)
                return attachedVehicleByFlatbed[entity] ~= nil
            end,
            onSelect = function(data)
                TriggerEvent('sc-cartow:unloadVehicle', data.entity)
            end,
        },
    })

    targetAdded[entity] = true
end

local function getNearestVehicle(flatbed)
    local flatbedCoords = GetEntityCoords(flatbed)
    local nearestVehicle = nil
    local nearestDistance = nil

    for _, vehicle in ipairs(GetGamePool('CVehicle')) do
        if vehicle ~= flatbed and not attachedFlatbedByVehicle[vehicle] then
            local distance = #(flatbedCoords - GetEntityCoords(vehicle))
            if distance <= Config.MaxDistance and (not nearestDistance or distance < nearestDistance) then
                nearestVehicle = vehicle
                nearestDistance = distance
            end
        end
    end

    return nearestVehicle
end

local function doProgress(duration, label)
    if progressActive then
        return false
    end

    progressActive = true

    local finished = exports.ox_lib:progressBar({
        duration = duration,
        label = label,
        useWhileDead = false,
        canCancel = false,
        disable = { car = true, move = true, mouse = false, combat = true },
        anim = {
            dict = 'anim@heists@box_carry@',
            clip = 'idle',
            flag = 49,
        },
    })

    progressActive = false
    return finished
end

local function getPlacementCoords(entity, offset)
    local entityCoords = GetEntityCoords(entity)
    local forward = GetEntityForwardVector(entity)
    local right = vector3(-forward.y, forward.x, 0.0)

    return vector3(
        entityCoords.x + (forward.x * offset.x) + (right.x * offset.y),
        entityCoords.y + (forward.y * offset.x) + (right.y * offset.y),
        entityCoords.z + offset.z
    )
end

AddEventHandler('sc-cartow:loadNearestVehicle', function(flatbed)
    if not DoesEntityExist(flatbed) then
        return
    end

    if attachedVehicleByFlatbed[flatbed] then
        notify('Вече има качена кола.', 'error')
        return
    end

    local vehicle = getNearestVehicle(flatbed)
    if not vehicle then
        notify('Няма близка кола.', 'error')
        return
    end

    if not doProgress(Config.LoadDuration, 'Качване на кола...') then
        return
    end

    AttachEntityToEntity(vehicle, flatbed, 0, Config.LoadOffset.x, Config.LoadOffset.y, Config.LoadOffset.z, Config.LoadRotation.x, Config.LoadRotation.y, Config.LoadRotation.z, false, false, true, false, 2, true)
    SetEntityCollision(vehicle, false, false)
    FreezeEntityPosition(vehicle, true)
    SetVehicleOnGroundProperly(vehicle)

    attachedVehicleByFlatbed[flatbed] = vehicle
    attachedFlatbedByVehicle[vehicle] = flatbed

    notify('Колата е качена.', 'success')
end)

AddEventHandler('sc-cartow:unloadVehicle', function(flatbed)
    local vehicle = attachedVehicleByFlatbed[flatbed]
    if not vehicle or not DoesEntityExist(vehicle) then
        attachedVehicleByFlatbed[flatbed] = nil
        notify('Няма качена кола.', 'error')
        return
    end

    if not doProgress(Config.UnloadDuration, 'Сваляне на кола...') then
        return
    end

    DetachEntity(vehicle, true, true)
    SetEntityCollision(vehicle, true, true)
    FreezeEntityPosition(vehicle, false)

    local unloadPos = getPlacementCoords(flatbed, Config.UnloadOffset)
    SetEntityCoords(vehicle, unloadPos.x, unloadPos.y, unloadPos.z, false, false, false, false)
    SetEntityHeading(vehicle, GetEntityHeading(flatbed))
    SetVehicleOnGroundProperly(vehicle)

    attachedVehicleByFlatbed[flatbed] = nil
    attachedFlatbedByVehicle[vehicle] = nil

    notify('Колата е свалена.', 'success')
end)

CreateThread(function()
    while true do
        for _, vehicle in ipairs(GetGamePool('CVehicle')) do
            if isFlatbedEntity(vehicle) then
                addTargetToFlatbed(vehicle)
            end
        end

        Wait(2000)
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end

    for vehicle, flatbed in pairs(attachedFlatbedByVehicle) do
        if DoesEntityExist(vehicle) then
            DetachEntity(vehicle, true, true)
            FreezeEntityPosition(vehicle, false)
        end
    end
end)
