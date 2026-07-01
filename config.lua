Config = {}

Config.Debug = false
Config.FlatbedModels = {
    'flatbed',
}

Config.MaxDistance = 6.5
Config.LoadOffset = vector3(0.0, -3.2, 0.8)
Config.LoadRotation = vector3(0.0, 0.0, 0.0)
Config.UnloadOffset = vector3(-7.1, 0.0, -0.6)
Config.LoadDuration = 5000
Config.UnloadDuration = 4000

Config.Notify = function(message, type)
    exports.ox_lib:notify({
        title = 'Репатрак',
        description = message,
        type = type or 'inform',
    })
end
