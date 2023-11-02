# Bus Driver Job

This is a script that I made for learning.

Modification from qbcore-busjob.

I will update soon as possible. Just download it for free.

# Installation
## Requirements
- FiveM
- QBCore
- ox_lib

Add to you server cfg:
- `ensure kuma-busjob`

Add your route from config

```
Config          = Config or {}

Config.Notify   = 'QBCore' -- 'QBCore', 'bcs hud', ditambahkan lagi besok :)
Config.Fuel     = 'LegacyFuel'
Config.Location = vector4(462.22, -641.15, 28.45, 175.0)

Config.Route    = {
    ['city']  = {
        Label        = 'Timur Kota',
        Payment      = 5000,
        TakeLocation = vector4(448.03, -582.57, 28.5, 261.48),
        Backlocation = vector4(460.86, -656.13, 27.75, 171.06),
        Location     = {
            vector4(466.67, -609.61, 28.5, 186.52),
            vector4(463.09, -639.15, 28.48, 173.81),
        }
    },
    ['city2'] = {
        Label        = 'Barat Kota',
        Payment      = 5000,
        TakeLocation = vector3(466.28, -584.77, 28.5),
        Backlocation = vector4(448.03, -582.57, 28.5, 261.48),
        Location     = {
            vector4(304.36, -764.56, 29.31, 252.09),
            vector4(-110.31, -1686.29, 29.31, 223.84),
            vector4(-712.83, -824.56, 23.54, 194.7),
            vector4(-692.63, -670.44, 30.86, 61.84),
            vector4(-250.14, -886.78, 30.63, 8.67),
        }
    },
}

function Notify(title, message, type, time)
    if Config.Notify == 'QBCore' then
        TriggerEvent('QBCore:Notify', message, type, time or 5000)
    end
end
```

# TODO
- Add marker for information ✅
- Add Quit job command / radial menu ❌
- 
