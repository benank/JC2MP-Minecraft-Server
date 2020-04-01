class 'Sky'

function Sky:__init()

    self.sky_dist = 300

    self.sun_image = Image.Create(AssetLocation.Resource, "Sun_IMG")
    self.sun_image:SetSize(Vector2(512,512))
    self.sun_model = self:CreateSprite(self.sun_image, self.sky_dist * 0.3)

    self.fog = Fog2({
        num_layers = 1,
        first_layer_dist = self.sky_dist,
        color = Color(76,176,247)
    })

    Events:Subscribe("GameRenderOpaque-1", self, self.GameRenderOpaque)

end

function Sky:GameRenderOpaque()
    self.fog:Render()
    local t = Transform3():Translate(Camera:GetPosition() + Vector3(0, self.sky_dist * 0.7, self.sky_dist * 0.7)):Rotate(Camera:GetAngle())
    Render:SetTransform(t)
    self.sun_model:Draw()
    Render:ResetTransform()
end

function Sky:CreateSprite(image, scale)
    local imageSize = image:GetSize()
    local size = Vector2(imageSize.x / imageSize.y, 1) / 2 * scale
    local uv1, uv2 = image:GetUV()
 
    local sprite = Model.Create({
       Vertex(Vector2(-size.x, size.y), Vector2(uv1.x, uv1.y)),
       Vertex(Vector2(-size.x,-size.y), Vector2(uv1.x, uv2.y)),
       Vertex(Vector2( size.x,-size.y), Vector2(uv2.x, uv2.y)),
       Vertex(Vector2( size.x,-size.y), Vector2(uv2.x, uv2.y)),
       Vertex(Vector2( size.x, size.y), Vector2(uv2.x, uv1.y)),
       Vertex(Vector2(-size.x, size.y), Vector2(uv1.x, uv1.y))
    })
 
    sprite:SetTexture(image)
    sprite:SetTopology(Topology.TriangleList)
 
    return sprite
end


Sky = Sky()