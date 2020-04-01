class 'Block'

local BLOCK_UID = 0

local function GET_BLOCK_UID()
    BLOCK_UID = BLOCK_UID + 1
    return BLOCK_UID
end

function Block:__init(pos, type, chunk)

    assert(type <= NUM_BLOCK_TYPES, "Invalid block type " .. tostring(type) .. " specified")
    self.position = pos
    self.type = type
    self.sorted_index = 0 -- Sorted index for ChunkVertices
    self.uid = GET_BLOCK_UID()
    self.chunk = chunk

    self.obj = ClientStaticObject.Create({
        position = self.position + Vector3(0.5, 0, 0.5),
        angle = Angle(),
        model = " ",
        collision = "34x09.flz/go003_lod1-a_col.pfx"
    })

    chunk.CSO_ids[self.obj:GetId()] = self

end

function Block:Remove(suppress_effect)
    if IsValid(self.obj) then
        self.obj:Remove()
    end
    
    if not suppress_effect then
        ClientEffect.Play(AssetLocation.Game, {
            effect_id = BlockDestructionFX[self.type],
            position = self.position + Vector3(0.5, 0.5, 0.5),
            angle = Angle()
        })
    end
end