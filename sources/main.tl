package.path = package.path .. ";./build/?.lua"

require("game")

local deltatime = require("externals/deltatime/deltatime")
local game = Game:new()

while true do
    local dt = deltatime.getTime()

    game:update(dt)

    window.clear(game.colors["gray"])
    game:draw()
    window.display()
end