class 'cChunkRemover'

function cChunkRemover:__init()

    self.chunks_to_remove = {}

    self.CHUNK_REMOVE_TIME = 15
    
    local func = coroutine.wrap(function()
        while true do
            
            for key, data in pairs(self.chunks_to_remove) do
                
                if data.timer:GetSeconds() > self.CHUNK_REMOVE_TIME then
                    self:DeleteChunk(data.chunk)
                    self.chunks_to_remove[key] = nil
                    Timer.Sleep(500)
                end

            end
            Timer.Sleep(1000)
        end
        
    end)()

end

function cChunkRemover:ContainsChunkAtCell(cell)
    return self.chunks_to_remove[PosToString(cell)]
end

--[[
    Add a chunk to the remove queue
]]
function cChunkRemover:AddChunk(chunk)
    if self:ContainsChunkAtCell(chunk.cell) then return end

    self.chunks_to_remove[PosToString(chunk.cell)] = {
        chunk = chunk,
        timer = Timer()
    }

end

--[[
    Remove a chunk from the remove queue
]]
function cChunkRemover:RemoveChunkByCell(cell)
    if not self:ContainsChunkAtCell(cell) then return end

    local chunk = self.chunks_to_remove[PosToString(cell)].chunk
    self.chunks_to_remove[PosToString(cell)] = nil

    return chunk
end

--[[
    Actually remove a chunk from the game
]]
function cChunkRemover:DeleteChunk(chunk)
    local cell = chunk.cell

    ChunkManager.chunks[cell.x][cell.y][cell.z] = nil
    chunk:Remove()
end

cChunkRemover = cChunkRemover()