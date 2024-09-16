global type Particle = record
    pos: Vector2
    vel: Vector2
    size: Vector2
    anim_ticks: number
end

global type Particles = record
    color: Color
    c_pos: Vector2
    data: { Particle }
end

function Particles:new(c_pos: Vector2, color: Color): Particles
    local self: Particles = setmetatable({}, { __index = Particles })

    self.color = color:copy()
    self.c_pos = c_pos:copy()
    self.data = {}

    for _ = 1, cmath.rand_int(5, 10) do
        local size <const> = cmath.rand_int(10, 15)
        local vel <const> = Vector2:new(cmath.rand_int(-6, 6), 50)
        local pos <const> = Vector2:new(
            cmath.rand_double(self.c_pos.x - size * 2, self.c_pos.x + size * 2),
            cmath.rand_double(self.c_pos.y - size * 2, self.c_pos.y + size * 2)
        )

        table.insert(self.data, {
            pos = pos,
            vel = vel,
            size = Vector2:new(size, size),
            anim_ticks = cmath.rand_double(1, 2)
        })
    end

    return self
end

function Particles:update(dt: number)
    for _, particle in ipairs(self.data) do
        particle.pos = particle.pos + (particle.vel * dt * 10)
        particle.anim_ticks = particle.anim_ticks - dt
    end
end

function Particles:draw()
    for _, particle in ipairs(self.data) do
        render.rectangle(
            math.floor(particle.pos.x),
            math.floor(particle.pos.y),
            math.floor(particle.size.x),
            math.floor(particle.size.y),
            Color:new(self.color.r, self.color.g, self.color.b, math.floor(self.color.a * particle.anim_ticks))
        )
    end
end

function Particles:isFade(): boolean
    for _, particle in ipairs(self.data) do
        if particle.anim_ticks > 0 then return false end
    end

    return true
end