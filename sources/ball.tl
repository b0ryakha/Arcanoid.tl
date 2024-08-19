global type Ball = record
    pos: Vector2
    vel: Vector2
    radius: number
    color: Color
    is_start: boolean
    bump_sound: Sound
    is_alive: boolean
end

function Ball:new(pos: Vector2, color: Color, radius: number): Ball
    local self: Ball = setmetatable({}, { __index = Ball })

    self.is_alive = true
    self.is_start = false
    self.radius = radius or 25
    self.pos = pos:copy() or Vector2:new(0, 0)
    self.vel = Vector2:new(0, 0)
    self.color = color:copy() or Color:new("#FFFFFF")

    self.bump_sound = Sound:new("./sounds/bump.wav", 10)

    return self
end

function Ball:update(dt: number)
    if not self.is_start then return end

    local speed <const> = 300

    if (self.pos.x - self.radius) < 0 then
        self.vel.x = -self.vel.x
        self.pos.x = self.radius
        self.bump_sound:play()
    end

    if (self.pos.x + self.radius) >= window.get_size().x then
        self.vel.x = -self.vel.x
        self.pos.x = window.get_size().x - self.radius
        self.bump_sound:play()
    end

    if (self.pos.y - self.radius) < 0 then
        self.vel.y = -self.vel.y
        self.pos.y = self.radius
        self.bump_sound:play()
    end

    self.pos = self.pos + (self.vel * dt * speed)

    -- is out of bounds:
    if (self.pos.y + self.radius) >= window.get_size().y then
        self.is_alive = false
    end
end

function Ball:start(vel: Vector2)
    if self.is_start then return end

    self.vel = vel
    self.is_start = true
end

function Ball:checkCollided(x: number, y: number, w: number, h: number): boolean
    -- closest point to center of circle on square:
    local closest_x = math.max(x, math.min(self.pos.x, x + w))
    local closest_y = math.max(y, math.min(self.pos.y, y + h))

    -- distance between center of circle and nearest point on square:
    local distance_x = self.pos.x - closest_x
    local distance_y = self.pos.y - closest_y
    
    -- is collided:
    local state = (distance_x ^ 2 + distance_y ^ 2) < (self.radius ^ 2)

    if state then
        if math.abs(distance_x) > math.abs(distance_y) then
            self.vel.x = -self.vel.x
        else
            self.vel.y = -self.vel.y
        end

        self.bump_sound:play()
    end

    return state
end

function Ball:modifyVel(vel: Vector2)
    self.vel = self.vel + vel
end

function Ball:draw()
    if not self.is_alive then return end
    render.circle(math.floor(self.pos.x), math.floor(self.pos.y), math.floor(self.radius), self.color)
end