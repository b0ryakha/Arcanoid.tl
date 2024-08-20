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
        ["arial"] = Font:new("arial.ttf", 50, "b")
    }

    self.musics = {
        ["track"] = Sound:new("./sounds/track.wav", 5, true),
        ["lose"] = Sound:new("./sounds/lose.wav", 10),
        ["win"] = Sound:new("./sounds/win.wav", 10)
    }

    self.colors = {
        ["gray"] = Color:new(50, 50, 50),
        ["black"] = Color:new(20, 20, 20)
    }

    return self
end

function Game:draw()
    if self.is_lose then
        local text <const> = "You have lost, your score is " .. self.score .. " points!"
        local measure <const> = render.measure_text(self.fonts["arial"], text)
        local win_size <const> = window.get_size()
        local x <const> = math.floor(win_size.x / 2 - measure.x / 2)
        local y <const> = math.floor(win_size.y / 2 - measure.y / 2)
        render.text(x, y, self.fonts["arial"], text, self.colors["black"])
    else
        self.player:draw()
        self.balls:draw()
        self.blocks:draw()
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
        self.is_start = false
        self.player:reset()

        self.musics["track"]:set_loop(false)
        self.musics["win"]:play()

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

        self.player:update(dt, self.balls)
        self.balls:update(dt)

        local breaks = self.blocks:update(dt, self.balls)
        self.score = self.score + breaks
    end
end