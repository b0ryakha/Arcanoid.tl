require("block")
require("ballmap")
require("player")

global type BlockMap = record
    data: { Block }
    metamethod __len: function(BlockMap): integer
end

function BlockMap:new(): BlockMap
    local self: BlockMap = setmetatable({}, {
        __index = BlockMap,
        __len = function(self: BlockMap): integer return #self.data end
    })

    self.data = {}

    if cmath.rand_int(0, 1) then
        
    end

    if cmath.rand_int(0, 1) then
        
    end

    if cmath.rand_int(0, 1) then
        
    end

    if not next(self.data) then
        local block_pad = 30
        local window_pad = 25
        local size = Vector2:new(50, 50)

        for i = 1, 17 do
            local pos = Vector2:new(size.x * (i - 1) + block_pad * i + window_pad, block_pad + window_pad)
            local hp = (i > 4 and i < 14) and 3 or 2
            table.insert(self.data, Block:new(pos, Color:new(100, 255, 100), size, hp))
        end

        for i = 2, 16 do
            local pos = Vector2:new(size.x * (i - 1) + block_pad * i + window_pad, block_pad * 2 + size.y + window_pad)
            table.insert(self.data, Block:new(pos, Color:new(100, 100, 255), size, 1))
        end
    end

    return self
end

function BlockMap:update(dt: number, balls: BallMap): integer
    local i = 1
    local breaks: integer = 0

    while i <= #self.data do
        if self.data[i]:isBreak() then
            if cmath.rand_int(0, 2) == 1 then
                balls:push(self.data[i].pos)
                balls:last():start(Vector2:new(cmath.rand_double(-1, 1), 1))
            end

            table.remove(self.data, i)
        else
            self.data[i]:update(dt, balls)

            if self.data[i]:isBreak() then
                breaks = breaks + 1
            end

            i = i + 1
        end
    end

    return breaks
end

function BlockMap:draw()
    for _, block in ipairs(self.data) do
        block:draw()
    end
end

function BlockMap:empty(): boolean
    return next(self.data) == nil
end