package.path = package.path .. ";./build/?.lua"

require("game")

local deltatime = require("externals/deltatime/deltatime")
local game = Game:new()

window.set_icon(Sprite:new("./images/ico.png", 200, 200))

while true do
    local dt = deltatime.getTime()

    game:update(dt)

    window.clear()
    game:draw()
    window.display()
end