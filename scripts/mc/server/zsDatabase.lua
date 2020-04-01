class 'sDatabase'

function sDatabase:__init()

    SQL:Execute("CREATE TABLE IF NOT EXISTS stats (blocks_placed INTEGER, blocks_destroyed INTEGER)")
    SQL:Execute("CREATE TABLE IF NOT EXISTS chunks (x INTEGER, y INTEGER, z INTEGER, blocks BLOB)")
    SQL:Execute("CREATE TABLE IF NOT EXISTS plots (x INTEGER, z INTEGER, name VARCHAR(20), owner_id VARCHAR(20), owner_name VARCHAR(50))")

    self.stats = {blocks_placed = 0, blocks_destroyed = 0}

    self:LoadStats()

    local func = coroutine.wrap(function()
        while true do

            Network:Broadcast("SyncStats", self.stats)
            self:SaveStats()
            Timer.Sleep(1000 * 60)

        end
    end)()
    Events:Subscribe("ClientModuleLoad", self, self.ClientModuleLoad)

    Events:Subscribe("PlayerRemoveBlock", self, self.PlayerRemoveBlock)
    Events:Subscribe("PlayerPlaceBlock", self, self.PlayerPlaceBlock)

end

function sDatabase:PlayerPlaceBlock(args)
    self.stats.blocks_placed = self.stats.blocks_placed + 1
end

function sDatabase:PlayerRemoveBlock(args)
    self.stats.blocks_destroyed = self.stats.blocks_destroyed + 1
end

function sDatabase:ClientModuleLoad(args)
    Network:Send(args.player, "SyncStats", self.stats)
end

function sDatabase:SaveStats()

    local result = SQL:Query("SELECT * FROM stats"):Execute()

    if #result > 0 then

        local update = SQL:Command("UPDATE stats SET blocks_placed = ?, blocks_destroyed = ?")
        update:Bind(1, self.stats.blocks_placed)
        update:Bind(2, self.stats.blocks_destroyed)
        update:Execute()
    
    else

		local command = SQL:Command("INSERT INTO stats (blocks_placed, blocks_destroyed) VALUES (?, ?)")
        command:Bind(1, self.stats.blocks_placed)
        command:Bind(2, self.stats.blocks_destroyed)
        command:Execute()
        
    end


end

function sDatabase:LoadStats()

    local result = SQL:Query("SELECT * FROM stats"):Execute()
    
    if #result > 0 then

        self.stats.blocks_placed = tonumber(result[1].blocks_placed)
        self.stats.blocks_destroyed = tonumber(result[1].blocks_destroyed)

    end

end

function sDatabase:LoadAllPlots()

    local result = SQL:Query("SELECT * FROM plots"):Execute()
    
    if #result > 0 then

        for _, plot_data in pairs(result) do

            sPlotManager:LoadPlotFromDB(plot_data)

        end

    end

end

function sDatabase:AddNewPlot(plot_data)
    
    local command = SQL:Command("INSERT INTO plots (x, z, name, owner_id, owner_name) VALUES (?, ?, ?, ?, ?)")
    command:Bind(1, plot_data.x)
    command:Bind(2, plot_data.z)
    command:Bind(3, plot_data.name)
    command:Bind(4, plot_data.owner_id)
    command:Bind(5, plot_data.owner_name)
    command:Execute()
        
end

function sDatabase:SerializeChunk(chunk)
    local str = ""

    for key, block in pairs(chunk.blocks) do
        str = str .. self:SerializeBlock(block) .. "|"
    end

    return str
end

function sDatabase:SerializeBlock(block)
    return string.format("%s,%s,%s,%s",
        tostring(block.position.x), tostring(block.position.y), tostring(block.position.z), tostring(block.type))
end

function sDatabase:SaveChunk(chunk)

    local cell = chunk.cell

    local result = SQL:Query("SELECT * FROM chunks where x = (?) AND y = (?) AND z = (?)")
    result:Bind(1, cell.x)
    result:Bind(2, cell.y)
    result:Bind(3, cell.z)
    result = result:Execute()

    if #result > 0 then
        -- Chunk already exists in DB, update it

        local update = SQL:Command("UPDATE chunks SET blocks = ? WHERE x = (?) AND y = (?) AND z = (?)")
        update:Bind(1, self:SerializeChunk(chunk))
        update:Bind(2, chunk.cell.x)
        update:Bind(3, chunk.cell.y)
        update:Bind(4, chunk.cell.z)
        update:Execute()
    
    else
        -- Chunk does not exist, so insert it
        
		local command = SQL:Command("INSERT INTO chunks (x, y, z, blocks) VALUES (?, ?, ?, ?)")
		command:Bind(1, chunk.cell.x)
		command:Bind(2, chunk.cell.y)
		command:Bind(3, chunk.cell.z)
		command:Bind(4, self:SerializeChunk(chunk))
        command:Execute()
        
    end

    
end

function sDatabase:LoadAllChunks()
    
    local result = SQL:Query("SELECT * FROM chunks"):Execute()
    
    if #result > 0 then

        local func = coroutine.wrap(function()
        
            for _, chunk_data in pairs(result) do

                local cell = {x = tonumber(chunk_data.x), y = tonumber(chunk_data.y), z = tonumber(chunk_data.z)}
                sChunkManager:AddChunkFromDB(cell, self:DeserializeBlocks(chunk_data.blocks))

            end

            Timer.Sleep(5)

        end)()

    end

end

function sDatabase:DeserializeBlocks(blocks)

    local split = blocks:split("|")
    local block_data = {}

    for _, block_str in pairs(split) do

        local block_split = block_str:split(",")

        if count_table(block_split) == 4 then
            local pos = Vector3(tonumber(block_split[1]), tonumber(block_split[2]), tonumber(block_split[3]))

            table.insert(block_data, {
                pos = pos,
                type = tonumber(block_split[4])
            })
        end

    end

    return block_data

end

sDatabase = sDatabase()
sDatabase:LoadAllPlots()
sDatabase:LoadAllChunks()