class 'ChunkManager'

function ChunkManager:__init()

    self.chunks = {} -- Chunks indexed by x, y
    self.adjacent_chunks = {}
    self.chunk_refresh_timer = Timer()

    self.pending_chunks = {}

    self.processing_chunks = 0
    self.max_chunks = 0

    self.initial_load_timer = Timer()
    self.initial_load = false
    Game:FireEvent("ply.pause")

    self.plot_lines_enabled = false
    
    local func = coroutine.wrap(function()
        while true do

            self.processing_chunks = count_table(self.pending_chunks)
            if count_table(self.pending_chunks) > 0 then
                
                self:ProcessPendingChunk(table.remove(self.pending_chunks, 1))
                Timer.Sleep(100)

            end

            Timer.Sleep(10)
        end
    end)()

    Events:Subscribe("GameRenderOpaque0", self, self.Render)
    Events:Subscribe("Cells/LocalPlayerCellUpdate" .. tostring(CHUNK_SIZE), self, self.LocalPlayerCellUpdate)
    Events:Subscribe("SecondTick", self, self.SecondTick)
    Events:Subscribe("ModuleUnload", self, self.ModuleUnload)


    Network:Subscribe("Chunk/UpdateBlock", self, self.ChunkUpdateBlock)
    Network:Subscribe("Chunk/Sync", self, self.ChunkSync)
    Network:Subscribe("Chunk/UpdateOwnerInfo", self, self.ChunkUpdateOwnerInfo)
end

function ChunkManager:ModuleUnload()
    Game:FireEvent("ply.pause")
end

function ChunkManager:SecondTick()
    
    if not self.initial_load or LocalPlayer:IsTeleporting() then
        
        if count_table(self.pending_chunks) == 0 and self.initial_load_timer:GetSeconds() > 10 then
            Game:FireEvent("ply.unpause")
            self.initial_load = true
        else
            Game:FireEvent("ply.pause")
        end
    end

end

function ChunkManager:ChunkUpdateOwnerInfo(args)

    local cell = args.cell

    if not self.chunks[cell.x] then self.chunks[cell.x] = {} end
    if not self.chunks[cell.x][cell.y] then self.chunks[cell.x][cell.y] = {} end

    local chunk = self.chunks[cell.x][cell.y][cell.z]

    if not chunk then return end

    chunk:UpdateOwnerInfo(args.owner_info)

end

function ChunkManager:ProcessPendingChunk(args)

    local done = 0
    local done_count = count_table(args.blocks)

    --debug("Adding " .. count_table(args.blocks) .. " blocks to cell " .. args.cell.x .. " " .. args.cell.y .. " " .. args.cell.z)
    for key, block_data in pairs(args.blocks) do

        if not args.refresh then
            local block = Block(block_data.position, block_data.type, args.chunk)
            args.chunk.blocks[key] = block
        elseif args.chunk.blocks[key].type ~= block_data.type then
            -- If this chunk already existed, just update it
            args.chunk:RemoveBlock(args.chunk.blocks[key])
            args.chunk:AddBlock(block_data.position, block_data.type)
            Timer.Sleep(1)
        end
        done = done + 1

        if done % 200 == 0 then
            Timer.Sleep(1)
        end

        if done == done_count and not args.refresh then
            args.chunk.chunk_vertices:AddBulk()
        end
    end

end

function ChunkManager:AddPendingChunk(data)

    table.insert(self.pending_chunks, {
        chunk = data.chunk,
        blocks = data.blocks,
        cell = data.cell,
        refresh = data.refresh
    })

    local current_cell = GetCell(Camera:GetPosition(), CHUNK_SIZE)

    table.sort(self.pending_chunks, function(a,b)
    
        return GetManhattanDistance(a.cell, current_cell) == GetManhattanDistance(b.cell, current_cell) and
            a.chunk.uid < b.chunk.uid or -- Randomly sort if cells are same distance 
            GetManhattanDistance(a.cell, current_cell) < GetManhattanDistance(b.cell, current_cell)
    
    end)

    self.max_chunks = count_table(self.pending_chunks)

end

function ChunkManager:ChunkSync(args)

    local cell = args.cell
    
    local current_cell = GetCell(Camera:GetPosition(), CHUNK_SIZE)
    if GetManhattanDistance(current_cell, args.cell) > 10 then return end

    if not self.chunks[cell.x] then self.chunks[cell.x] = {} end
    if not self.chunks[cell.x][cell.y] then self.chunks[cell.x][cell.y] = {} end

    local chunk = self.chunks[cell.x][cell.y][cell.z]

    if chunk then

        self:AddPendingChunk({
            cell = cell,
            chunk = chunk,
            blocks = args.blocks,
            refresh = true
        })

        return

    end

    if not chunk then
        chunk = Chunk(cell, args.owner_info)
        self.chunks[cell.x][cell.y][cell.z] = chunk
    end

    self:AddPendingChunk({
        cell = cell,
        chunk = chunk,
        blocks = args.blocks
    })

end

function ChunkManager:ChunkUpdateBlock(args)
    
    local cell = args.cell

    -- Chunk does not exist (should already be synced, even if empty)
    if not self.chunks[cell.x] or not self.chunks[cell.x][cell.y] or not self.chunks[cell.x][cell.y][cell.z] then return end

    if args.active then
        -- Block was added
        self.chunks[cell.x][cell.y][cell.z]:AddBlock(args.block_data.position, args.block_data.type)
    else
        -- Block was removed
        self.chunks[cell.x][cell.y][cell.z]:RemoveBlockByPos(args.block_data.position)
    end

    self.chunks[cell.x][cell.y][cell.z]:Regenerate()
end

function ChunkManager:LocalPlayerCellUpdate(args)
    
    local cell = args.cell
    local adjacent_chunks = args.adjacent

    --debug("MY CURRENT CELL: " .. cell.x .. " " .. cell.y .. " " .. cell.z)
    
    -- Sort adjacent chunks so the render order is correct (TODO: sort based on camera angle)
    table.sort(adjacent_chunks, function(a,b) 
        return GetManhattanDistance(a, cell) > GetManhattanDistance(b, cell) end)

    self.adjacent_chunks = adjacent_chunks

    --[[for _, adj_cell in pairs(self.adjacent_chunks) do
        debug("ADJACENT CELL: " .. adj_cell.x .. " " .. adj_cell.y .. " " .. adj_cell.z)
    end]]

    local chunks_to_remove = {}

    for _, _cell in pairs(args.old_adjacent) do
        if self.chunks[_cell.x] and self.chunks[_cell.x][_cell.y] and self.chunks[_cell.x][_cell.y][_cell.z] then

            local chunk = self.chunks[_cell.x][_cell.y][_cell.z]

            local can_remove = true
            for _, chunk_data in pairs(self.pending_chunks) do
                if chunk_data.cell.x ~= _cell.x or chunk_data.cell.y ~= _cell.y or chunk_data.cell.z ~= _cell.z then
                    can_remove = false
                    break
                end
            end

            if can_remove then
                cChunkRemover:AddChunk(chunk)
            end
        end
    end

    --[[for _, cell in pairs(self.adjacent_chunks) do

        local can_remove = true
        for _, chunk_data in pairs(self.pending_chunks) do
            if chunk_data.cell.x ~= _cell.x or chunk_data.cell.y ~= _cell.y or chunk_data.cell.z ~= _cell.z then
                can_remove = false
                break
            end
        end

        cChunkRemover:RemoveChunkByCell(cell)
    end]]

    -- TODO: only enable collision for adjacent chunks (with range = 1)

end

function ChunkManager:Render(args)
    for _, cell in ipairs(self.adjacent_chunks) do
        if self.chunks[cell.x] and self.chunks[cell.x][cell.y] and self.chunks[cell.x][cell.y][cell.z] then
            local chunk = self.chunks[cell.x][cell.y][cell.z]
            chunk:Render()
        end
    end
end

-- Only called by Hotbar for local changes
function ChunkManager:RemoveBlock(id)

    local current_cell = GetCell(Camera:GetPosition(), CHUNK_SIZE)

    local adjacent_chunks = GetAdjacentCells(current_cell, 1)

    for _, adj_cell in pairs(adjacent_chunks) do
        if self.chunks[adj_cell.x] and self.chunks[adj_cell.x][adj_cell.y] and self.chunks[adj_cell.x][adj_cell.y][adj_cell.z] then
            
            local block = self.chunks[adj_cell.x][adj_cell.y][adj_cell.z].CSO_ids[id]
            
            if block then

                if block.type == BlockType.Bedrock then
                    Chat:Print("Cannot break this block!", Color.Red)
                    return
                end

                local chunk = self.chunks[adj_cell.x][adj_cell.y][adj_cell.z]

                if chunk.owner_info.owner_id and chunk.owner_info.owner_id ~= tostring(LocalPlayer:GetSteamId()) then
                    Chat:Print("You do not have permission to build here!", Color.Red)
                    return
                end
            
                chunk:RemoveBlock(block)

                Network:Send("ChunkManager/RemoveBlock", {
                    position = block.position,
                    cell = adj_cell
                })

                break
            end
        end
    end


end

-- Only called by Hotbar for local changes
function ChunkManager:SpawnBlock(pos, type)

    pos = Vector3(math.floor(pos.x), math.floor(pos.y), math.floor(pos.z))
    local cell = GetCell(pos, CHUNK_SIZE)

    if not self.chunks[cell.x]
    or not self.chunks[cell.x][cell.y]
    or not self.chunks[cell.x][cell.y][cell.z] then return end

    local chunk = self.chunks[cell.x][cell.y][cell.z]

    if chunk.owner_info.owner_id and chunk.owner_info.owner_id ~= tostring(LocalPlayer:GetSteamId()) then
        Chat:Print("You do not have permission to build here!", Color.Red)
        return
    end

    chunk:AddBlock(pos, type)

    Network:Send("ChunkManager/SpawnBlock", {
        position = pos,
        type = type
    })

end

ChunkManager = ChunkManager()