class 'sBlock'

function sBlock:__init(pos, type)

    assert(type <= NUM_BLOCK_TYPES, "Invalid block type " .. tostring(type) .. " specified")
    self.position = pos
    self.type = type

end

function sBlock:GetSyncObject()
    return {
        type = self.type,
        position = self.position
    }
end