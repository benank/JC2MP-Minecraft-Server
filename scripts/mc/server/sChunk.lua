class 'sChunk'

function sChunk:__init(cell, initial_blocks, owner_info)

    self.cell = cell
    self.position = GetPosFromCell(self.cell, CHUNK_SIZE)
    self.model = nil
    self.blocks = initial_blocks or {} -- All blocks in chunk

    self.owner_info = owner_info or {} -- name, owner_id, owner_name
end

function sChunk:SetOwnerInfo(plot_data)

    if not plot_data then return end

    self.owner_info = 
    {
        owner_id = plot_data.owner_id,
        name = plot_data.name,
        owner_name = plot_data.owner_name
    }

    local players = sPlayerCellManager:GetPlayersInAdjacentCells(self.cell, 2)

    if count_table(players) > 0 then
        Network:SendToPlayers(players, "Chunk/UpdateOwnerInfo", {
            cell = self.cell,
            owner_info = self.owner_info
        })
    end
end

function sChunk:RemoveBlock(position, player)
    local block = self.blocks[PosToString(position)]

    if not block then return end -- No block exists at this position

    if block.type == BlockType.Bedrock then
        Chat:Print("Cannot break this block!", Color.Red)
        return
    end

    if self.owner_info.owner_id and self.owner_info.owner_id ~= tostring(player:GetSteamId()) then
        Chat:Print("You do not have permission to build here!", Color.Red)
        return
    end


    local key = PosToString(position)

    self.blocks[key] = nil

    self:SyncOneBlockToAdjacentPlayers(block)
    
    if self.owner_info.owner_id then
        sDatabase:SaveChunk(self)
    end

    Events:Fire("PlayerRemoveBlock", {
        player = player
    })

end

function sChunk:AddBlock(pos, type, player)
    if self.blocks[PosToString(pos)] then return end -- A block is already at this position

    if not InventoryBlocks[type] then
        Chat:Print("Cannot place this block type!", Color.Red)
        return
    end

    if self.owner_info.owner_id and self.owner_info.owner_id ~= tostring(player:GetSteamId()) then
        Chat:Print("You do not have permission to build here!", Color.Red)
        return
    end


    local block = sBlock(pos, type)

    self.blocks[PosToString(block.position)] = block

    self:SyncOneBlockToAdjacentPlayers(block)
    
    if self.owner_info.owner_id then
        sDatabase:SaveChunk(self)
    end

    Events:Fire("PlayerPlaceBlock", {
        player = player
    })

end

function sChunk:SyncOneBlockToAdjacentPlayers(block)
    local key = PosToString(block.position)
    local active = self.blocks[key] ~= nil

    local data = {
        active = active,
        block_data = block:GetSyncObject(),
        cell = self.cell
    }

    local players = sPlayerCellManager:GetPlayersInAdjacentCells(self.cell, 2)

    if count_table(players) > 0 then
        Network:SendToPlayers(players, "Chunk/UpdateBlock", data)
    end
end

function sChunk:SyncToPlayer(player)
    Network:Send(player, "Chunk/Sync", {
        blocks = self:GetSyncObject(),
        cell = self.cell,
        owner_info = self.owner_info
    })
end

function sChunk:GetSyncObject()
    local data = {}

    for key, block in pairs(self.blocks) do
        data[key] = block:GetSyncObject()
    end

    return data

end