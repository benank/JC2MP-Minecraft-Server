Events:Subscribe("PlayerJoin", function(args)
    Chat:Send(args.player, "Welcome to ", Color.White, "Minecraft Creative Mode", Color(255,0,255), "!", Color.White)
    Chat:Send(args.player, " ", Color.White)
    SendPlayerCommands(args.player)
end)

function SendPlayerCommands(player)

    Chat:Send(player, "Commands:", Color.White)
    Chat:Send(player, "/spawn", Color.Yellow, " - Teleports you to spawn", Color.White)
    Chat:Send(player, "/plotlines", Color.Yellow, " - Turns plot lines on or off", Color.White)
    Chat:Send(player, "/claimplot name", Color.Yellow, " - Claims the plot that you are currently in and gives it a name", Color.White)
    Chat:Send(player, "/myplots", Color.Yellow, " - Lists out all the names of plots you own", Color.White)
    Chat:Send(player, "/toplot name", Color.Yellow, " - Teleports you to the plot with specified name", Color.White)
    Chat:Send(player, "/controls", Color.Yellow, " - Display the controls", Color.White)
    Chat:Send(player, "/help", Color.Yellow, " - Display these commands again", Color.White)

end

function SendPlayerControls(player)

    Chat:Send(player, "Controls:", Color.White)
    Chat:Send(player, "Left Click", Color.Yellow, " - destroy block", Color.White)
    Chat:Send(player, "Right Click", Color.Yellow, " - place block", Color.White)
    Chat:Send(player, "Scroll", Color.Yellow, " - change block", Color.White)
    Chat:Send(player, "E", Color.Yellow, " - open block selector menu", Color.White)
    Chat:Send(player, "F5", Color.Yellow, " - toggle first person view", Color.White)
    Chat:Send(player, "Double tap jump", Color.Yellow, " - toggle fly mode", Color.White)
    Chat:Send(player, "Shift", Color.Yellow, " - move faster in fly mode", Color.White)
    Chat:Send(player, "Space", Color.Yellow, " - move up in fly mode", Color.White)
    Chat:Send(player, "Ctrl", Color.Yellow, " - move down in fly mode", Color.White)

end


Events:Subscribe("PlayerChat", function(args)

    local split = args.text:split(" ")

    if args.text == "/spawn" then
        args.player:SetPosition(sSpawn.SPAWN_LOCATION)
        return false
    elseif split[1] == "/claimplot" then
        sChunkManager:TryClaimChunk(split[2], args.player)
        return false
    elseif split[1] == "/myplots" then
        sPlotManager:ListPlayerPlots(args.player)
        return false
    elseif split[1] == "/toplot" then
        sPlotManager:TeleportToPlot(split[2], args.player)
        return false
    elseif split[1] == "/help" then
        SendPlayerCommands(args.player)
        return false
    elseif split[1] == "/controls" then
        SendPlayerControls(args.player)
        return false
    end

end)