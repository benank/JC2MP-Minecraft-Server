class 'Hotbar'

BLOCK_INTERACT_RANGE = 12

function Hotbar:__init()

    self.selected_index = 1 -- Index from 1-9
    self.scale = 0.75 -- Scale of the hotbar
    self.items = 
    {
        [1] = BlockType.Dirt,
        [2] = BlockType.GrassBlock,
        [3] = BlockType.StoneBrick,
        [4] = BlockType.Brick,
        [5] = BlockType.Sand,
        [6] = BlockType.Dirt,
        [7] = BlockType.Stone,
        [8] = BlockType.WoodenPlank,
        [9] = BlockType.SmoothStoneBrick
    }

    self.models = {}

    self:CreateHotbar()

    Events:Subscribe("MouseUp", self, self.MouseUp)
    Events:Subscribe("MouseScroll", self, self.MouseScroll)

end

function Hotbar:MouseUp(args)

    if Game:GetState() ~= GUIState.Game then return end
    if Inventory.open then return end

    if args.button == 1 then
        -- Left click
        local ray = Physics:Raycast(Camera:GetPosition(), Camera:GetAngle() * Vector3.Forward, 0, BLOCK_INTERACT_RANGE)
        local entity = ray.entity

        if not entity or entity.__type ~= "ClientStaticObject" then return end

        ChunkManager:RemoveBlock(entity:GetId())
        LocalPlayer:SetLeftArmState(AnimationState.LaSHookMissed)

    elseif args.button == 2 then
        -- Right click
        
        local ray = Physics:Raycast(Camera:GetPosition(), Camera:GetAngle() * Vector3.Forward, 0, BLOCK_INTERACT_RANGE)

        -- Can only place blocks on other blocks
        if not ray.entity or ray.entity.__type ~= "ClientStaticObject" then return end

        local pos = ray.position - Camera:GetAngle() * Vector3.Forward * 0.01
        local type = self.items[self.selected_index]

        if not InventoryBlocks[type] then
            Chat:Print("Cannot place this block type!", Color.Red)
            return
        end
    
        ChunkManager:SpawnBlock(pos, self.items[self.selected_index])
        LocalPlayer:SetLeftArmState(AnimationState.LaSHookMissed)
        
        local sound = ClientSound.Create(AssetLocation.Game, {
            bank_id = 12,
            sound_id = 24,
            position = pos,
            angle = Angle()
        })

        sound:SetParameter(0,0)
        sound:SetParameter(1,0)
        sound:SetParameter(2,1)
        sound:Play()

    end
end

function Hotbar:Render(args)
    local num_items = count_table(self.items)
    local add = self.hotbar_image:GetSize().x / 9
    for index, model in ipairs(self.models) do
        local t = Transform2():Translate(
            self.hotbar_panel:GetPosition() 
            + Vector2(add * (index - 0.5),
             self.hotbar_selected_panel:GetSize().y / 2)):Rotate(math.pi)
        Render:SetTransform(t)
        model:Draw()
        Render:ResetTransform()
    end
end

function Hotbar:MouseScroll(args)
    if Game:GetState() ~= GUIState.Game then return end

    local change = math.ceil(args.delta)

    self.selected_index = self.selected_index - change

    if self.selected_index > 9 then
        self.selected_index = 1
    elseif self.selected_index < 1 then
        self.selected_index = 9
    end

    self.hotbar_selected_panel:SetPositionRel(Vector2((self.selected_index - 1) / 9 - 0.001 * self.selected_index, 0))

end

function Hotbar:UpdateIcons()

    for index, block_type in ipairs(self.items) do
        local vertices = {}
        local model = self:CreateSprite(BLOCK_IMAGE, self.hotbar_image:GetSize().y * 0.5, block_type)
        model:Set2D(true)

        self.models[index] = model
    
    end

end

function Hotbar:CreateHotbar()

    self.hotbar_image = Image.Create(AssetLocation.Resource, "Hotbar_IMG")
    local BASE_HOTBAR_SIZE = Vector2(1000, 121)
    self.hotbar_image:SetSize(BASE_HOTBAR_SIZE * self.scale)

    self.hotbar_panel = ImagePanel.Create()
    self.hotbar_panel:SetImage(self.hotbar_image)
    self.hotbar_panel:SetSize(self.hotbar_image:GetSize() + Vector2(0, 0))
    self.hotbar_panel:SetPosition(
        Vector2(Render.Size.x / 2, Render.Size.y - 20) - Vector2(self.hotbar_panel:GetSize().x / 2, self.hotbar_panel:GetSize().y))

    self.hotbar_image_selected = Image.Create(AssetLocation.Resource, "Hotbar_Selected_IMG")
    local BASE_HOTBAR_SELECTED_SIZE = Vector2(120, 120)
    self.hotbar_image_selected:SetSize(BASE_HOTBAR_SELECTED_SIZE * self.scale)

    self.hotbar_selected_panel = ImagePanel.Create(self.hotbar_panel)
    self.hotbar_selected_panel:SetImage(self.hotbar_image_selected)
    self.hotbar_selected_panel:SetSize(self.hotbar_image_selected:GetSize())
    self.hotbar_selected_panel:SetPositionRel(Vector2(0, 0))

    self.hotbar_panel:Subscribe("Render", self, self.Render)
    
    self:UpdateIcons()
end

function Hotbar:CreateSprite(image, scale, block_type)
    local tex_id = BlockUVOriginal[block_type].tex
    local imageSize = image:GetSize()
    local size = Vector2(1, 1) / 2 * scale
    local uv1, uv2 = 
        Vector2(BLOCK_IMAGE_SIZE.x * ((tex_id - 1) / NUM_BLOCK_IMAGES), 0), 
        Vector2(BLOCK_IMAGE_SIZE.x * ((tex_id) / NUM_BLOCK_IMAGES), 1)
    
    uv1.x = uv1.x / BLOCK_IMAGE_SIZE.x
    uv2.x = uv2.x / BLOCK_IMAGE_SIZE.x
 
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

Hotbar = Hotbar()