require("player")
require("blockmap")
require("ballmap")

global type Game = record
    is_start: boolean
    is_lose: boolean
    score: integer

    colors: { string : Color }
    sprites: { string : Sprite }
    fonts: { string : Font }

    player: Player
    blocks: BlockMap
    balls: BallMap
    musics: { string : Sound }
end

function Game:init()
    self.is_start = false
    self.is_lose = false
    self.score = 0

    self.player = Player:new()
    self.blocks = BlockMap:new()
    self.balls = BallMap:new()
    self.balls:push(Vector2:new(self.player.cx, self.player.cy - 40))
end

function Game:new(): Game
    local self: Game = setmetatable({}, { __index = Game })
    self:init()

    self.fonts = {
        ["arial"] = Font:new("arial.ttf", 50)
    }

    self.musics = {
        ["main"] = Sound:new("./sounds/music.wav", 5, true),
        ["end"] = Sound:new("./sounds/end.wav", 5, false)
    }

    self.colors = {
        ["gray"] = Color:new(50, 50, 50),
        ["light_gray"] = Color:new(150, 150, 150)
    }

    return self
end

function Game:draw()
    if self.is_lose then
        local text <const> = "Вы проиграли! Ваш счет: " .. self.score .. "."
        local measure <const> = render.measure_text(self.fonts["arial"], text)
        local win_size <const> = window.get_size()
        local x <const> = math.floor(win_size.x / 2 - measure.x / 2)
        local y <const> = math.floor(win_size.y / 2 - measure.y / 2)
        render.text(x, y, self.fonts["arial"], text, self.colors["light_gray"])
    else
        self.player:draw()
        self.balls:draw()
        self.blocks:draw()
    end
end

function Game:update(dt: number)
    -- loss:
    if self.balls:empty() then
        self.musics["main"]:stop()
        self.musics["end"]:play()
        self.is_lose = true
    end

    -- start & restart:
    if keyboard.is_pressed(key.Space) or keyboard.is_pressed(key.Enter) then
        if self.is_lose then
            self:init()
        elseif not self.is_start then
            self.balls:first():start(Vector2:new(0, -1))
            self.musics["main"]:play()
            self.is_start = true
        end
    end

    -- update:
    window.set_title("Arcanoid.tl | Score: " .. self.score)
    
    if not self.is_lose and self.is_start then
        self.player:update(dt, self.balls)
        self.balls:update(dt)

        local breaks = self.blocks:update(dt, self.balls)
        self.score = self.score + breaks
    end
end