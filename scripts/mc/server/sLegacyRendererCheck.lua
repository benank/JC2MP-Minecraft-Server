Network:Subscribe("LegacyRendererEnabled", function(args, player)
    player:Kick("You must disable Legacy Renderer in order to play on this server.")
end)