class 'RenderManager'

function RenderManager:__init()

    Events:Subscribe("GameRenderOpaque", self, self.GameRenderOpaque)
end

function RenderManager:GameRenderOpaque(args)

    Events:Fire("GameRenderOpaque-1", args)
    Events:Fire("GameRenderOpaque0", args)
    Events:Fire("GameRenderOpaque1", args)
    Events:Fire("GameRenderOpaque2", args)

end

RenderManager = RenderManager()