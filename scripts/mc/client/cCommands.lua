Events:Subscribe("LocalPlayerChat", function(args)
    if args.text == "/plotlines" then
        ChunkManager.plot_lines_enabled = not ChunkManager.plot_lines_enabled
        return false
    end
end)