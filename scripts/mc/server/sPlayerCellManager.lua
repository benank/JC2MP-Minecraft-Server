class 'sPlayerCellManager'

function sPlayerCellManager:__init()

    self.players = {} -- Players, indexed by cell x,y,z

    Events:Subscribe("PlayerQuit", self, self.PlayerQuit)
    Events:Subscribe("Cells/PlayerCellUpdate" .. tostring(CHUNK_SIZE), self, self.PlayerCellUpdate)
end

function sPlayerCellManager:PlayerCellUpdate(args)

    -- If they existed in an old cell previously
    if args.old_cell
    and self.players[args.old_cell.x]
    and self.players[args.old_cell.x][args.old_cell.y]
    and self.players[args.old_cell.x][args.old_cell.y][args.old_cell.z] then
        
        -- Remove them
        self.players[args.old_cell.x][args.old_cell.y][args.old_cell.z][tostring(args.player:GetSteamId())] = nil

    end

    if not self.players[args.cell.x] then self.players[args.cell.x] = {} end
    if not self.players[args.cell.x][args.cell.y] then self.players[args.cell.x][args.cell.y] = {} end
    if not self.players[args.cell.x][args.cell.y][args.cell.z] then self.players[args.cell.x][args.cell.y][args.cell.z] = {} end

    -- Now add them to the new cell
    self.players[args.cell.x][args.cell.y][args.cell.z][tostring(args.player:GetSteamId())] = args.player


end

function sPlayerCellManager:GetPlayersInAdjacentCells(cell)
    local players = {}

    local adjacent_cells = GetAdjacentCells(cell, CHUNK_SIZE)

    -- Get all players in adjacent cells
    for _, cell in pairs(adjacent_cells) do

        if self.players[cell.x]
        and self.players[cell.x][cell.y]
        and self.players[cell.x][cell.y][cell.z] then

            for id, player in pairs(self.players[cell.x][cell.y][cell.z]) do
                table.insert(players, player)
            end

        end
    end

    return players
end

function sPlayerCellManager:PlayerQuit(args)
    local cell = args.player:GetValue("Cell")
    if not cell then return end

    local cell_mc = cell[CHUNK_SIZE]
    if not cell_mc then return end

    -- Cell does not exist
    if not self.players[cell_mc.x]
    or not self.players[cell_mc.x][cell_mc.y]
    or not self.players[cell_mc.x][cell_mc.y][cell_mc.z] then return end

    -- Remove player from cell
    self.players[cell_mc.x][cell_mc.y][cell_mc.z][tostring(args.player:GetSteamId())] = nil
end

sPlayerCellManager = sPlayerCellManager()