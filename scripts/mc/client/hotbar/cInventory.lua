class 'Inventory'

function Inventory:__init()

    self.scale = 1.0 -- Scale of the inventory
    self.models = {}

    self.open_key = 'E'
    self.open = false

    self.selected_button = nil

    self.claim_points = 0

    self:CreateInventory()

    Events:Subscribe("SecondTick", self, self.SecondTick)
    Events:Subscribe("KeyUp", self, self.KeyUp)

end

function Inventory:SecondTick()
    local data = LocalPlayer:GetValue("PlayerData")
    if not data then return end

    self.claim_points = data.claim_points
end

function Inventory:KeyUp(args)

    if args.key == string.byte(self.open_key) then
        self:ToggleOpen()
    end
    
end

function Inventory:ToggleOpen()
    self.open = not self.open
    Mouse:SetPosition(Render.Size / 2)
    Mouse:SetVisible(self.open)
    self.selected_button = nil

    if self.open then
        self.lpi = Events:Subscribe("LocalPlayerInput", self, self.LocalPlayerInput)
        self.inventory_panel:Show()
        self.inventory_panel:BringToFront()
    else
        Events:Unsubscribe(self.lpi)
        self.lpi = nil
        self.inventory_panel:Hide()
    end

end

function Inventory:LocalPlayerInput(args)
    return false
end

function Inventory:PressHotbarButton(button)

    if Game:GetState() ~= GUIState.Game or not self.selected_button then return end

    Hotbar.items[button:GetDataNumber("index")] = self.selected_button:GetDataNumber("type")
    Hotbar:UpdateIcons()
    self.selected_button = nil
end

function Inventory:PressItemButton(button)

    if Game:GetState() ~= GUIState.Game then return end

    if self.selected_button then
        self.selected_button = nil
        return
    end

    self.selected_button = button
end

function Inventory:Render(args)

    Render:DrawText(
        self.inventory_panel:GetPosition() + Vector2(26, 20), 
        string.format("Block Selection (Plot Points: %d)", self.claim_points), 
        Color.Black, 
        30)

    for index, rectangle in pairs(self.rectangles) do
        local t = Transform2():Translate(
            self.inventory_panel:GetPosition() + rectangle:GetPosition() + rectangle:GetSize() / 2):Rotate(math.pi)
        Render:SetTransform(t)

        local model = self.models[index]
        model:Draw()
        Render:ResetTransform()
    end

    for index, rectangle in ipairs(self.hotbar_rectangles) do
        local t = Transform2():Translate(
            self.inventory_panel:GetPosition() + rectangle:GetPosition() + rectangle:GetSize() / 2):Rotate(math.pi)
        Render:SetTransform(t)

        local model = Hotbar.models[index]
        model:Draw()
        Render:ResetTransform()
    end

    if self.selected_button then
        local t = Transform2():Translate(Mouse:GetPosition()):Rotate(math.pi)
        Render:SetTransform(t)

        local model = self.models[self.selected_button:GetDataNumber("index")]
        model:Draw()
        Render:ResetTransform()
    end

end

function Inventory:UpdateIcons()

    local index = 1

    local start_pos = Vector2(26, 60)
    local size = Vector2(56,56)
    local margin = Vector2(5.5, 5.5)

    local running_pos = start_pos

    self.rectangles = {}

    for block_type, enabled in pairs(InventoryBlocks) do
        
        local rectangle = Rectangle.Create(self.inventory_panel)
        rectangle:SetColor(Color(255, 0, 0, 0))
        rectangle:SetSize(Vector2(56,56))
        rectangle:SetPosition(running_pos)

        local button = Button.Create(rectangle)
        button:SetSizeRel(Vector2(1,1))
        button:SetBackgroundVisible(false)
        button:SetDataNumber("index", index)
        button:SetDataNumber("type", block_type)
        button:SetToolTip(BlockNames[block_type])

        button:Subscribe("Press", self, self.PressItemButton)

        if index % 9 == 0 then
            running_pos = running_pos + Vector2(0, size.y + margin.y) - Vector2(size.x + margin.x, 0) * 8
        else
            running_pos = running_pos + Vector2(size.x + margin.x, 0)
        end
        
        self.rectangles[index] = rectangle

        local vertices = {}
        local model = self:CreateSprite(BLOCK_IMAGE, size.x * 0.8, block_type)
        model:Set2D(true)

        self.models[index] = model

        index = index + 1
    
    end

    
    start_pos = Vector2(26, 444)

    running_pos = start_pos

    self.hotbar_rectangles = {}

    for index, block_type in ipairs(Hotbar.items) do
        
        local rectangle = Rectangle.Create(self.inventory_panel)
        rectangle:SetColor(Color(255, 0, 0, 0))
        rectangle:SetSize(Vector2(56,56))
        rectangle:SetPosition(running_pos)

        running_pos = running_pos + Vector2(size.x + margin.x, 0)
        
        self.hotbar_rectangles[index] = rectangle

        local button = Button.Create(rectangle)
        button:SetSizeRel(Vector2(1,1))
        button:SetBackgroundVisible(false)
        button:SetDataNumber("index", index)

        button:Subscribe("Press", self, self.PressHotbarButton)

    end


end

function Inventory:CreateInventory()

    self.inventory_image = Image.Create(AssetLocation.Resource, "Inventory_IMG")
    local BASE_INVENTORY_SIZE = Vector2(600, 527)
    self.inventory_image:SetSize(BASE_INVENTORY_SIZE * self.scale)

    self.inventory_panel = ImagePanel.Create()
    self.inventory_panel:SetImage(self.inventory_image)
    self.inventory_panel:SetSize(self.inventory_image:GetSize())
    self.inventory_panel:SetPosition(Render.Size / 2 - self.inventory_panel:GetSize() / 2)
    self.inventory_panel:Hide()

    self.inventory_panel:Subscribe("Render", self, self.Render)

    self:UpdateIcons()
end

function Inventory:CreateSprite(image, scale, block_type)
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

Inventory = Inventory()