global type Particle = record
    pos: Vector2
    vel: Vector2
    size: Vector2
end

global type Particles = record
    color: Color
    c_pos: Vector2
    data: { Particle }
    live_ticks: number
end

function Particles:new(c_pos: Vector2, color: Color): Particles
    local self: Particles = setmetatable({}, { __index = Particles })

    self.color = color:copy()
    self.c_pos = c_pos:copy()
    self.data = {}
    self.live_ticks = 1.6

    for _ = 1, cmath.rand_int(5, 10) do
        local size <const> = cmath.rand_int(10, 15)
        local vel <const> = Vector2:new(cmath.rand_int(-6, 6), 50)
        local pos <const> = Vector2:new(
            cmath.rand_double(self.c_pos.x - size * 2, self.c_pos.x + size * 2),
            cmath.rand_double(self.c_pos.y - size * 2, self.c_pos.y + size * 2)
        )

        table.insert(self.data, {
            pos = pos,
            size = Vector2:new(size, size),
            vel = vel
        })
    end

    return self
end

function Particles:update(dt: number)
    for _, particle in ipairs(self.data) do
        particle.pos = particle.pos + (particle.vel * dt * 10)
    end

    self.live_ticks = self.live_ticks - dt
end

function Particles:draw()
    for _, particle in ipairs(self.data) do
        render.rectangle(
            math.floor(particle.pos.x),
            math.floor(particle.pos.y),
            math.floor(particle.size.x),
            math.floor(particle.size.y),
            self.color
        )
    end
end