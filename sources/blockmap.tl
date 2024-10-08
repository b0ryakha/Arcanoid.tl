require("block")
require("ballmap")

global type BlockMap = record
    data: { Block }
    metamethod __len: function(BlockMap): integer

    -- pre decl:
    empty: function(BlockMap): boolean
end

local enum BlockTile
    "#" -- red
    "@" -- yellow
    "$" -- green
    "&" -- blue
end

local block_color = {
    ["#"] = Color:new(150, 50, 50),
    ["@"] = Color:new(200, 200, 110),
    ["$"] = Color:new(100, 180, 60),
    ["&"] = Color:new(80, 80, 190)
}

function BlockMap:spawnByArt(block_size: Vector2, art: { string })
    local block_pad <const> = 30
    local win_pad <const> = Vector2:new(70, 50)
    local win_size <const> = window.get_size()
    local max_blocks_x <const> = math.floor((win_size.x - win_pad.x) / (block_size.x + block_pad))
    local max_blocks_y <const> = math.floor((win_size.y - win_pad.y) / (block_size.y + block_pad))

    for row = 1, max_blocks_y do
        if row > #art then break end

        for column = 1, max_blocks_x do
            if column > #art[row] then break end

            if art[row]:sub(column, column) ~= ' ' then
                local color = block_color[art[row]:sub(column, column) as BlockTile]
                local pos = Vector2:new(
                    block_size.x * (column - 1) + block_pad * column + win_pad.x,
                    block_size.y * (row - 1) + block_pad * row + win_pad.y
                )
                
                table.insert(self.data, Block:new(pos, color, block_size, cmath.rand_int(1, 3)))
            end
        end
    end
end

function BlockMap:removeCollisions()
    local i = 1

    while i <= #self.data do
        local need_remove = false

        for j = i + 1, #self.data do
            if self.data[i]:isCollided(self.data[j]) then
                need_remove = true
                break
            end
        end

        if need_remove then
            table.remove(self.data, i)
        else
            i = i + 1
        end
    end
end

function BlockMap:spawn()
    self.data = {}

    if cmath.rand_int(1, 100) <= 80 then
        self:spawnByArt(Vector2:new(50, 50), {
            "#",
            "@#&",
            "@###$",
            "@#&",
            "#",
        })
    end

    if cmath.rand_int(1, 100) <= 80 then
        self:spawnByArt(Vector2:new(50, 50), {
            "               #",
            "             &#@",
            "           $###@",
            "             &#@",
            "               #",
        })
    end

    if cmath.rand_int(1, 100) <= 30 then
        self:spawnByArt(Vector2:new(50, 50), {
            "  ###    &&     ",
            "             @@ ",
            "     #$$        ",
            " @@@   &&&&&&&& ",
        })
    end

    -- TODO: rework to using art
    if not next(self.data) then
        self:spawnByArt(Vector2:new(50, 50), {
            "       &&       ",
            "  $    ##    $  ",
            "       &&       ",
            " @@@        @@@ ",
        })
    end

    self:removeCollisions()
end

function BlockMap:new(): BlockMap
    local self: BlockMap = setmetatable({}, {
        __index = BlockMap,
        __len = function(self: BlockMap): integer return #self.data end
    })

    self:spawn()

    return self
end

function BlockMap:update(dt: number, balls: BallMap, pmanager: PManager): integer
    local i = 1
    local breaks: integer = 0

    while i <= #self.data do
        if self.data[i]:isBreak() then
            if cmath.rand_int(0, 2) == 1 then
                balls:push(self.data[i].c_pos)
                balls:last():start(Vector2:new(cmath.rand_double(-1, 1), 1))
            end

            breaks = breaks + 1
            table.remove(self.data, i)
        else
            self.data[i]:update(dt, balls, pmanager)
            i = i + 1
        end
    end

    return breaks
end

function BlockMap:draw()
    for _, block in ipairs(self.data) do
        block:draw()
    end
end

function BlockMap:empty(): boolean
    return next(self.data) == nil
end