class 'sChunkManager'

function sChunkManager:__init()

    self.chunks = {} -- Chunks indexed by cell x, y, z

    local func = coroutine.wrap(function()
        while true do

            if os.date("%H") == 0 then -- 12:00 am
                self:ClearAllUnprotectedChunks()
            end

            Timer.Sleep(1000 * 60 * 60)
        end
    end)()

    Events:Subscribe("Cells/PlayerCellUpdate" .. tostring(CHUNK_SIZE), self, self.PlayerCellUpdate)

    Network:Subscribe("ChunkManager/RemoveBlock", self, self.PlayerRemoveBlock)
    Network:Subscribe("ChunkManager/SpawnBlock", self, self.PlayerSpawnBlock)
    
end

-- Called when a player claims a plot and we need to update all the chunks in it
function sChunkManager:UpdateClaimedPlot(plot_data)

    if not self.chunks[plot_data.x] then return end

    for y, _ in pairs(self.chunks[plot_data.x]) do
        local chunk = self.chunks[plot_data.x][y][plot_data.z]

        if chunk then
            chunk:SetOwnerInfo(plot_data)
            sDatabase:SaveChunk(chunk)
        end
    end

end

-- Called when a player tries to claim the chunk they are in
-- Claims the entire range of x,z coords so they get everything in the height
function sChunkManager:TryClaimChunk(name, player)

    -- TODO: check player's claim points to see if they can claim a plot

    local data = player:GetValue("PlayerData")
    if not data then return end

    if data.claim_points == 0 then
        Chat:Send(player, "You do not have enough plot points to claim a plot!", Color.Red)
        return
    end
        

    local cell = GetCell(player:GetPosition(), CHUNK_SIZE)

    if not self.chunks[cell.x]
    or not self.chunks[cell.x][cell.y] 
    or not self.chunks[cell.x][cell.y][cell.z] then return end

    local chunk = self.chunks[cell.x][cell.y][cell.z]

    if chunk.owner_info.owner_id then
        Chat:Send(player, "This plot is already claimed by another player!", Color.Red)
        return
    end

    local adjacent_chunks = GetAdjacentCells(cell, 1)

    for _, adj_cell in pairs(adjacent_chunks) do

        local plot = sPlotManager:GetPlotXZ(adj_cell.x, adj_cell.z)
        if self:IsChunkXZClaimed(adj_cell.x, adj_cell.z) and plot and plot.owner_id ~= tostring(player:GetSteamId()) then
            Chat:Send(player, "The plot you are trying to claim is too close to another claimed plot!", Color.Red)
            return
        end

    end

    if not name then
        Chat:Send(player, "You must specify a plot name!", Color.Red)
        return
    end


    name = name:trim()

    if name:len() < 3 then
        Chat:Send(player, "Invalid plot name specified.", Color.Red)
        return
    end

    if name:len() > 20 then
        Chat:Send(player, "Plot name is too long! Must be less than 20 characters.", Color.Red)
        return
    end

    if sPlotManager.plots[name:lower()] then
        Chat:Send(player, "This plot name is already taken!", Color.Red)
        return
    end

    -- Seems good, let's claim it!
    sPlotManager:AddPlot(cell, name, player)

end

-- Checks if the x,z coords of a chunk are claimed
function sChunkManager:IsChunkXZClaimed(x, z)

    if not self.chunks[x] then return false end

    for y, _ in pairs(self.chunks[x]) do
        if self.chunks[x][y] then
            local chunk = self.chunks[x][y][z]

            if chunk then
                if chunk.owner_info.owner_id then
                    return true
                end
            end
        end
    end

    return false

end

function sChunkManager:ClearAllUnprotectedChunks()

    for p in Server:GetPlayers() do
        p:Kick("Clearing all unprotected plots. This is an automatic action and you may rejoin the server.")
    end

    -- clear all chunks without owners
    for x, _ in pairs(self.chunks) do
        for y, _ in pairs(self.chunks[x]) do
            for z, _ in pairs(self.chunks[x][y]) do
                local chunk = self.chunks[x][y][z]

                -- No owner, remove it
                if not chunk.owner_info.name then
                    self.chunks[x][y][z] = nil
                end
            end
        end
    end

end

function sChunkManager:PlayerRemoveBlock(args, player)
    if not args.position then return end
    
    local cell = args.cell

    -- Chunk doesn't exist
    if not self.chunks[cell.x]
    or not self.chunks[cell.x][cell.y]
    or not self.chunks[cell.x][cell.y][cell.z] then return end

    self.chunks[cell.x][cell.y][cell.z]:RemoveBlock(args.position, player)

end

function sChunkManager:PlayerSpawnBlock(args, player)
    if not args.position or not args.type then return end

    local cell = GetCell(args.position, CHUNK_SIZE)

    -- Chunk doesn't exist
    if not self.chunks[cell.x]
    or not self.chunks[cell.x][cell.y]
    or not self.chunks[cell.x][cell.y][cell.z] then return end

    self.chunks[cell.x][cell.y][cell.z]:AddBlock(args.position, args.type, player)

end

function sChunkManager:PlayerCellUpdate(args)

    if not args.player:GetValue("ReadyToLoadChunks") then
        args.player:SetValue("ReadyToLoadChunks", 
        args.cell.x == sSpawn.SPAWN_CELL.x and args.cell.y == sSpawn.SPAWN_CELL.y and args.cell.z == sSpawn.SPAWN_CELL.z)
    end

    if not args.player:GetValue("ReadyToLoadChunks") then return end

    local sync_data = {}

    local func = coroutine.wrap(function()
        
        for _, cell in pairs(args.updated) do

            -- Make sure the chunk exists
            self:GenerateChunkIfNeeded(cell)

            self.chunks[cell.x][cell.y][cell.z]:SyncToPlayer(args.player)
            
            Timer.Sleep(10)

        end
    end)()

end

function sChunkManager:AddChunkFromDB(cell, block_data)

    local blocks = {}

    for _, data in pairs(block_data) do
        local block = sBlock(data.pos, data.type)
        blocks[PosToString(block.position)] = block
    end

    local chunk = sChunk(cell, blocks)
    
    local owner_info = sPlotManager:IsChunkInPlot(chunk)
    chunk:SetOwnerInfo(owner_info)

    if not self.chunks[cell.x] then self.chunks[cell.x] = {} end
    if not self.chunks[cell.x][cell.y] then self.chunks[cell.x][cell.y] = {} end

    self.chunks[cell.x][cell.y][cell.z] = chunk

end

--[[
    Generates a chunk if there is no preexisting chunk that exists at the cell
]]
function sChunkManager:GenerateChunkIfNeeded(cell)

    -- First verify that we have a spot for it
    if not self.chunks[cell.x] then self.chunks[cell.x] = {} end
    if not self.chunks[cell.x][cell.y] then self.chunks[cell.x][cell.y] = {} end
    
    
    -- If it doesn't exist, make one
    if not self.chunks[cell.x][cell.y][cell.z] then

        self.chunks[cell.x][cell.y][cell.z] = sChunk(cell, sDefaultChunkGenerator:GenerateDefaultChunk(cell))

    end


end

sChunkManager = sChunkManager()