class 'Crosshair'

function Crosshair:__init()

    self.scale = 0.4
    
    self.crosshair_image = Image.Create(AssetLocation.Resource, "Crosshair_IMG")
    self.crosshair_image:SetSize(Vector2(128, 128) * self.scale)

    self.crosshair_panel = ImagePanel.Create()
    self.crosshair_panel:SetImage(self.crosshair_image)
    self.crosshair_panel:SetSize(self.crosshair_image:GetSize())
    self.crosshair_panel:SetPosition(Render.Size / 2 - self.crosshair_panel:GetSize() / 2)


    Events:Subscribe("Render", self, self.Render)
end

function Crosshair:Render()
    Game:FireEvent("gui.aim.hide")
    Game:FireEvent("gui.crosshair.hide")
end

Crosshair = Crosshair()
