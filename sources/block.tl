require("ballmap")

global type Block = record
    c_pos: Vector2
    size: Vector2
    color: Color
    is_alive: boolean
    hp: integer
    break_sound: Sound
    cracks_sprite: Sprite
    cracks_count: integer
    immunity: number
    anim_ticks: number
end

function Block:new(center_pos: Vector2, color: Color, size: Vector2, hp: integer): Block
    local self: Block = setmetatable({}, { __index = Block })

    self.is_alive = true
    self.size = size:copy() or Vector2:new(50, 50)
    self.c_pos = center_pos:copy() or Vector2:new(0, 0)
    self.color = color:copy() or Color:new("#FFFFFF")
    self.hp = hp or 1
    self.immunity = 0
    self.anim_ticks = 0

    self.break_sound = Sound:new("./sounds/break.wav", 10)

    self.cracks_sprite = Sprite:new("./images/cracks.png", 40, 40)
    self.cracks_sprite:set_pos(math.floor(self.c_pos.x), math.floor(self.c_pos.y))
    self.cracks_sprite:set_origin(size.x, size.y)
    self.cracks_count = 0

    return self
end

function Block:update(dt: number, balls: BallMap)
    if not self.is_alive then
        self.anim_ticks = self.anim_ticks - dt
        if self.anim_ticks < 0 then self.anim_ticks = 0 end

        self.size.x = cmath.lerp(self.size.x, 0, dt * 10)
        self.size.y = cmath.lerp(self.size.y, 0, dt * 10)
        self.color.a = cmath.lerp(self.color.a, 0, dt * 10) as integer

        return
    end

    if self.immunity <= 0 and balls:getCollided(self.c_pos.x - self.size.x / 2, self.c_pos.y - self.size.y / 2, self.size.x, self.size.y) then
        self.break_sound:play(true)
        self.cracks_count = self.cracks_count + 1
    
        self.hp = self.hp - 1

        if self.hp <= 0 then
            self.is_alive = false
            self.anim_ticks = 0.2
        else
            self.immunity = 0.5
        end
    end

    self.immunity = self.immunity - dt
end

function Block:isBreak(): boolean
    return (not self.is_alive) and (self.anim_ticks <= 0)
end

function Block:isCollided(block: Block): boolean
    local self_pos = self.c_pos - (self.size / 2)
    local block_pos = block.c_pos - (block.size / 2)

    return (
        (self_pos.x < block_pos.x + block.size.x) and
        (self_pos.x + self.size.x > block_pos.x) and
        (self_pos.y < block_pos.y + block.size.y) and
        (self_pos.y + self.size.y > block_pos.y)
    )
end

function Block:draw()
    if self:isBreak() then return end

    render.rectangle(
        math.floor(self.c_pos.x - self.size.x / 2),
        math.floor(self.c_pos.y - self.size.y / 2),
        math.floor(self.size.x),
        math.floor(self.size.y),
        self.color
    )

    -- cracks:
    if not self.is_alive then return end

    for i = 1, self.cracks_count do
        self.cracks_sprite:set_rotation(i * 45)
        render.sprite(self.cracks_sprite)
    end
end