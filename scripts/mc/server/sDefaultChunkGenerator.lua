class 'sDefaultChunkGenerator'

function sDefaultChunkGenerator:__init()

    self.FLOOR_HEIGHT = math.floor(sSpawn.SPAWN_LOCATION.y / CHUNK_SIZE) - 1

end

-- If the cell height is equal to a certian amount, then grass is generated. Otherwise, nothing
function sDefaultChunkGenerator:GenerateDefaultChunk(cell)

    if cell.y == self.FLOOR_HEIGHT then

        return self:GenerateFloor(cell)

    else
        return {}
    end

end

function sDefaultChunkGenerator:GenerateFloor(cell)

    local pos = GetPosFromCell(cell, CHUNK_SIZE)
    local blocks = {}

    -- TODO: optimize this in a coroutine
    for x = 0, CHUNK_SIZE - 1 do
        for z = 0, CHUNK_SIZE - 1 do
            
            local block = sBlock(pos + Vector3(x, 0, z), BlockType.Bedrock)
            blocks[PosToString(block.position)] = block

            local block = sBlock(pos + Vector3(x, CHUNK_SIZE - 1, z), BlockType.GrassBlock)
            blocks[PosToString(block.position)] = block

        end
    end

    return blocks

end

sDefaultChunkGenerator = sDefaultChunkGenerator()
