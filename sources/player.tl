require("ballmap")

global type Player = record
    cx: number
    cy: number
    size: Vector2
    color: Color
end

local old_cx: number = 0
local old_cy: number = 0

function Player:new(cx: integer): Player
    local self: Player = setmetatable({}, { __index = Player })

    self.size = Vector2:new(200, 20)
    self.color = Color:new(255, 150, 100)

    self.cx = cx or (window.get_size().x / 2)
    self.cy = window.get_size().y - self.size.y - 50

    old_cx = self.cx
    old_cy = self.cy

    return self
end

function Player:update(dt: number, balls: BallMap)
    local speed = 380
    local border_x <const> = math.floor(window.get_size().x / 26)

    -- movement:
    if keyboard.is_pressed(key.LShift) then
        speed = speed * 2
    end
    if keyboard.is_pressed(key.A) or keyboard.is_pressed(key.Left) then
        if (self.cx - self.size.x / 2) > border_x then
            self.cx = self.cx - speed * dt
        end
    end
    if keyboard.is_pressed(key.D) or keyboard.is_pressed(key.Right) then
        if (self.cx + self.size.x / 2) < (window.get_size().x - border_x) then
            self.cx = self.cx + speed * dt
        end
    end

    -- update:
    local collided_bal = balls:getCollided(self.cx - self.size.x / 2, self.cy, self.size.x, self.size.y) as Ball

    if collided_bal then
        local ball_x <const> = collided_bal.pos.x
        local p_start <const> = self.cx - self.size.x / 2
        local dist = math.abs(self.cx - ball_x) / 100
    
        if ball_x >= p_start and ball_x <= self.cx then
            dist = dist * -1
        end
    
        collided_bal:modifyVel(Vector2:new(dist, 0))
        collided_bal.pos.y = self.cy - collided_bal.radius
    end
end

function Player:draw()
    for i = 0, 2, 0.5 do
        render.rectangle(
            math.floor(self.cx - self.size.x / 2 + i * 50),
            math.floor(self.cy + i * 50),
            math.floor(self.size.x - i * 100),
            math.floor(self.size.y - i * 15),
            Color:new(self.color.r, self.color.g, self.color.b, math.floor(self.color.a - 230 * i))
        )
    end
end

function Player:get_pos(): Vector2
    return Vector2:new(self.cx, self.cy)
end

function Player:reset()
    self.cx = old_cx
    self.cy = old_cy
end