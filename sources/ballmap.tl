require("ball")

global type BallMap = record
    data: { Ball }
    metamethod __len: function(BallMap): integer
end

function BallMap:new(): BallMap
    local self: BallMap = setmetatable({}, {
        __index = BallMap,
        __len = function(self: BallMap): integer return #self.data end
    })

    self.data = {}

    return self
end

function BallMap:first(): Ball
    return self.data[1]
end

function BallMap:last(): Ball
    return self.data[#self.data]
end

function BallMap:push(pos: Vector2, radius: number | nil)
    table.insert(self.data, Ball:new(
        pos,
        Color:new(cmath.rand_int(100, 200), cmath.rand_int(100, 200), cmath.rand_int(100, 200)),
        radius or 25
    ))
end

function BallMap:update(dt: number)
    local i = 1

    while i <= #self.data do
        if not self.data[i].is_alive then
            table.remove(self.data, i)
        else
            self.data[i]:update(dt)

            i = i + 1
        end
    end
end

function BallMap:draw()
    for _, ball in ipairs(self.data) do
        ball:draw()
    end
end

function BallMap:empty(): boolean
    return next(self.data) == nil
end

function BallMap:keepOnlyFirst()
    self.data = { self:first() }
end

function BallMap:getCollided(x: number, y: number, w: number, h: number): Ball | nil
    for _, ball in ipairs(self.data) do
        if ball:checkCollided(x, y, w, h) then return ball end
    end

    return nil
end