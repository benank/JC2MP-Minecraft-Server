class 'sSpawn'

function sSpawn:__init()

    self.SPAWN_LOCATION = Vector3(40008, 2005, 40008)
    self.SPAWN_CELL = GetCell(self.SPAWN_LOCATION, CHUNK_SIZE)


    Events:Subscribe("Cells/PlayerCellUpdate" .. tostring(CHUNK_SIZE), self, self.PlayerCellUpdate)
    Events:Subscribe("PlayerSpawn", self, self.PlayerSpawn)
end

function sSpawn:PlayerCellUpdate(args)
    local player_pos = args.player:GetPosition()

    if player_pos.y < self.SPAWN_LOCATION.y - 100 then

        -- Teleport player back to spawn
        args.player:SetPosition(self.SPAWN_LOCATION)

    end
end

function sSpawn:PlayerSpawn(args)

    args.player:SetPosition(self.SPAWN_LOCATION)
    return false
    
end

sSpawn = sSpawn()