require("player")
require("blockmap")
require("ballmap")
require("pmanager")

global type Game = record
    is_start: boolean
    is_lose: boolean
    score: integer
    bg_id: integer

    colors: { string : Color }
    sprites: { string : Sprite }
    fonts: { string : Font }

    pmanager: PManager
    player: Player
    blocks: BlockMap
    balls: BallMap
    musics: { string : Sound }
end

function Game:init()
    self.is_start = false
    self.is_lose = false
    self.score = 0
    self.bg_id = cmath.rand_int(1, 5)

    self.pmanager = PManager:new()
    self.player = Player:new()
    self.blocks = BlockMap:new()
    self.balls = BallMap:new()
    self.balls:push(Vector2:new(self.player.cx, self.player.cy - 40))
end

function Game:new(): Game
    local self: Game = setmetatable({}, { __index = Game })
    self:init()

    self.fonts = {
        ["arial"] = Font:new("arial.ttf", 50, "b")
    }

    self.musics = {
        ["track"] = Sound:new("./sounds/track.wav", 5, true),
        ["lose"] = Sound:new("./sounds/lose.wav", 10),
        ["win"] = Sound:new("./sounds/win.wav", 10)
    }

    self.colors = {
        ["white"] = Color:new(200, 200, 200)
    }

    self.sprites = {}

    for i = 0, 4 do
        self.sprites["bg" .. (i + 1)] = Sprite:new("./images/bg.png",
            math.floor(window.get_size().x),
            math.floor(window.get_size().y),
            i * 224, 0,
            224, 240
        )
    end

    return self
end

function Game:draw()
    if self.is_lose then
        local text <const> = "You have lost, your score is " .. self.score .. " points!"
        local measure <const> = render.measure_text(self.fonts["arial"], text)
        local win_size <const> = window.get_size()
        local x <const> = math.floor(win_size.x / 2 - measure.x / 2)
        local y <const> = math.floor(win_size.y / 2 - measure.y / 2)
        render.text(x, y, self.fonts["arial"], text, self.colors["white"])
    else
        render.sprite(self.sprites["bg" .. self.bg_id])
        
        self.pmanager:draw()
        self.balls:draw()
        self.blocks:draw()
        self.player:draw()
    end
end

function Game:update(dt: number)
    -- loss:
    if self.balls:empty() and not self.is_lose then
        self.musics["track"]:stop()
        self.musics["lose"]:play()
        self.is_lose = true
    end

    -- force win:
    if keyboard.is_pressed(key.LAlt) and keyboard.is_pressed(key.F1) then
        self.blocks.data = {}
    end

    -- win:
    if self.blocks:empty() then
        self.bg_id = cmath.rand_int(1, 5)

        self.is_start = false
        self.player:reset()

        self.musics["track"]:set_loop(false)
        self.musics["win"]:play(true)

        self.balls:keepOnlyFirst()
        self.balls:first().pos = Vector2:new(self.player.cx, self.player.cy - 40)

        self.blocks:spawn()
    end

    -- start & restart:
    if keyboard.is_pressed(key.Space) or keyboard.is_pressed(key.Enter) then
        if self.is_lose then
            self:init()
        elseif not self.is_start then
            self.balls:first():start(Vector2:new(0, -1))
            self.musics["track"]:play()
            self.is_start = true
        end
    end

    -- update:
    window.set_title("Arcanoid.tl | Score: " .. self.score)
    
    if not self.is_lose and self.is_start then
        if not self.musics["track"]:is_play() then
            self.musics["track"]:set_loop(true)
            self.musics["track"]:play(true)
        end

        self.pmanager:update(dt)
        self.player:update(dt, self.balls)
        self.balls:update(dt)

        local breaks = self.blocks:update(dt, self.balls, self.pmanager)
        self.score = self.score + breaks
    end
end