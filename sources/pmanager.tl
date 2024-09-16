require("particles")

global type PManager = record
    data: { Particles }
end

function PManager:new(): PManager
    local self: PManager = setmetatable({}, { __index = PManager })

    self.data = {}

    return self
end

function PManager:update(dt: number)
    local i = 1

    while i <= #self.data do
        if self.data[i]:isFade() then
            table.remove(self.data, i)
        else
            self.data[i]:update(dt)

            i = i + 1
        end
    end
end

function PManager:draw()
    for _, particles in ipairs(self.data) do
        particles:draw()
    end
end

function PManager:spawn(c_pos: Vector2, color: Color)
    table.insert(self.data, Particles:new(c_pos, color))
end