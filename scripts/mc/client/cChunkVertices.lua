class 'ChunkVertices'

--[[
    Storage and management class for the vertices of a chunk
]]
function ChunkVertices:__init(chunk)

    self.chunk = chunk
    self.vertices = {} -- table of vertices to draw, sorted by draw order
    self.blocks_sorted = {} -- Blocks sorted by render order
    self.recreate_needed = false -- If the model needs to be recreated because a block was destroyed

end

function ChunkVertices:GetBlockInsertIndex(block)
    if block.sorted_index == 0 then
        error("ChunkVertices:GetBlockInsertIndex failed, sorted_index was 0")
        return
    end

    return (block.sorted_index - 1) * 36 + 1
end

function ChunkVertices:Sort()
    
    self.blocks_sorted = {}

    for _, block in pairs(self.chunk.blocks) do
        table.insert(self.blocks_sorted, block)
    end

    table.sort(self.blocks_sorted, function(a,b) return self:GetBlockOrder(a, b) end)

    for index, block in ipairs(self.blocks_sorted) do
        block.sorted_index = index
    end

end

function ChunkVertices:GetBlockOrder(a, b)
    return BlockRenderOrder[a.type] == BlockRenderOrder[b.type] and
        a.uid < b.uid or
        BlockRenderOrder[a.type] < BlockRenderOrder[b.type]
end

function ChunkVertices:AddBlock(block)
    self:Sort()
    GetBlockCompleteMap(block.type, block.position, self.chunk.position, self.vertices, self:GetBlockInsertIndex(block))
end

function ChunkVertices:AddBulk()
    self:Sort()
    Timer.Sleep(1)

    local count = 0
    local max_count = count_table(self.blocks_sorted)
    for index, block in ipairs(self.blocks_sorted) do
        GetBlockCompleteMap(block.type, block.position, self.chunk.position, self.vertices, self:GetBlockInsertIndex(block))
        
        count = count + 1

        if count % 6 == 0 then
            Timer.Sleep(1)
        end

        if count == max_count then
            Timer.Sleep(1)
            self.chunk:Regenerate()
        end
    end

end

function ChunkVertices:RemoveBlock(block)

    self:Sort()
    local start_index = self:GetBlockInsertIndex(block)

    for i = 1, 36 do
        table.remove(self.vertices, start_index)
    end

    self.recreate_needed = true

end