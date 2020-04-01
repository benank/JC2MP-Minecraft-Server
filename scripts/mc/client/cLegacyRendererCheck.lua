local timer = Timer()

Events:Subscribe("GameRender", function()
    if not Render:GetDepthEnabled() and timer:GetSeconds() > 1 then
        timer:Restart()
        Network:Send("LegacyRendererEnabled")
    end
end)