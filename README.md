# sc-cartow

Прост Qbox/ox_target addon за качване и сваляне на най-близка кола към flatbed.

## Какво прави
- При поглед към flatbed с ox_target се появяват опции:
  - "Качи кола"
  - "Свали кола"
- При качване се избира най-близката кола в радиус до 6.5 метра.
- Има ox_lib progressbar при качване и сваляне.
- Когато е качена, колата е прикрепена към flatbed и не може да се избере повторно.

## Настройки
В [config.lua](config.lua) можеш да промениш:
- моделите, които се считат за flatbed
- максимално разстояние
- позиция/rotation при качване
- продължителността на progressbar

## Инсталация
1. Постави папката в resources.
2. Добави в server.cfg:
   ensure ox_lib
   ensure ox_target
   ensure qbx_core
   ensure sc-cartow
3. Ако имаш друг модел flatbed, добави го в Config.FlatbedModels в [config.lua](config.lua).

# ВСИЧКИ ПРАВА ЗАПАЗЕНИ!!
