global type Ball = record
    pos: Vector2
    vel: Vector2
    radius: number
    color: Color
    sprite: Sprite
    is_start: boolean
    bump_sound: Sound
    is_alive: boolean
end

function Ball:new(pos: Vector2, color: Color, radius: number): Ball
    local self: Ball = setmetatable({}, { __index = Ball })

    self.is_alive = true
    self.is_start = false
    self.radius = radius
    self.pos = pos:copy()
    self.vel = Vector2:new(0, 0)
    self.color = color:copy()

    local d = math.floor(self.radius * 2)
    self.sprite = Sprite:new("./images/ball.png", d, d)
    self.sprite:set_color(self.color)

    self.bump_sound = Sound:new("./sounds/bump.wav", 10)

    return self
end

function Ball:update(dt: number)
    if not self.is_start then return end

    local speed <const> = 300

    local win_size <const> = window.get_size()
    local border_x <const> = math.floor(win_size.x / 26)
    local border_y <const> = math.floor(win_size.y / 30)

    if (self.pos.x - self.radius) < border_x then
        self.vel.x = -self.vel.x
        self.pos.x = self.radius + border_x
        self.bump_sound:play(true)
    end

    if (self.pos.x + self.radius) > (win_size.x - border_x) then
        self.vel.x = -self.vel.x
        self.pos.x = win_size.x - self.radius - border_x
        self.bump_sound:play(true)
    end

    if (self.pos.y - self.radius) < border_y then
        self.vel.y = -self.vel.y
        self.pos.y = border_y + self.radius
        self.bump_sound:play(true)
    end

    self.pos = self.pos + (self.vel * dt * speed)

    -- is out of bounds:
    if (self.pos.y - self.radius) > win_size.y then
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

        self.bump_sound:play(true)
    end

    return state
end

function Ball:modifyVel(vel: Vector2)
    self.vel = self.vel + vel
end

function Ball:draw()
    if not self.is_alive then return end

    self.sprite:set_pos(math.floor(self.pos.x - self.radius), math.floor(self.pos.y - self.radius))
    render.sprite(self.sprite)
end