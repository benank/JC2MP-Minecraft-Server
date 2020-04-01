class 'sPlotManager'

function sPlotManager:__init()

    self.plots = {} -- Plot coords x,z, indexed by plot name
    self.plots_x_z = {} -- Plots indexed by xz

end

function sPlotManager:GetPlotXZ(x,z)
    
    if not self.plots_x_z[x] then return end

    if self.plots_x_z[x][z] then
        return self.plots_x_z[x][z]
    end

end

function sPlotManager:IsChunkInPlot(chunk)
    return self:GetPlotXZ(chunk.cell.x, chunk.cell.z)
end

function sPlotManager:LoadPlotFromDB(plot_data)

    self.plots[plot_data.name:lower()] = plot_data
    
    if not self.plots_x_z[tonumber(plot_data.x)] then self.plots_x_z[tonumber(plot_data.x)] = {} end

    self.plots_x_z[tonumber(plot_data.x)][tonumber(plot_data.z)] = plot_data

end

function sPlotManager:AddPlot(cell, name, player)

    local plot_data = {
        name = name,
        owner_id = tostring(player:GetSteamId()),
        owner_name = player:GetName(),
        x = cell.x,
        z = cell.z
    }

    self.plots[name:lower()] = plot_data

    if not self.plots_x_z[cell.x] then self.plots_x_z[cell.x] = {} end

    self.plots_x_z[cell.x][cell.z] = plot_data

    sChunkManager:UpdateClaimedPlot(plot_data)
    sDatabase:AddNewPlot(plot_data)
    
    local data = player:GetValue("PlayerData")
    data.claim_points = data.claim_points - 1
    player:SetNetworkValue("PlayerData", data)

    sClaimPoints:UpdatePlayer(player)

    Chat:Send(player, "Plot successfully claimed!", Color.Green)
end

function sPlotManager:ListPlayerPlots(player)
    -- Send a chat message with all player plots
    local msg = "Your plots: "
    
    for name, plot_data in pairs(self.plots) do
        if plot_data.owner_id == tostring(player:GetSteamId()) then
            msg = msg .. plot_data.name .. ", "
        end
    end

    msg = msg:sub(1, msg:len() - 2) -- Get rid of last comma

    Chat:Send(player, msg, Color.White)
end

function sPlotManager:TeleportToPlot(plotname, player)
    local plot = self.plots[plotname:lower()]

    if plot then

        local pos = GetPosFromCell({x = plot.x, y = 0, z = plot.z}, CHUNK_SIZE)
        pos = pos + Vector3(CHUNK_SIZE / 2, sSpawn.SPAWN_LOCATION.y, CHUNK_SIZE / 2)
        player:SetPosition(pos)
        Chat:Send(player, "Teleported to plot ", Color.Green, plotname, Color.Yellow)

    else
        Chat:Send(player, "Plot does not exist", Color.Red)
    end
end

sPlotManager = sPlotManager()