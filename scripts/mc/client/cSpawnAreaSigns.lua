class 'SpawnAreaSigns'

function SpawnAreaSigns:__init()

    self.spawn_position = Vector3(40008, 2005, 40008)
    self.spawn_cell = GetCell(self.spawn_position, CHUNK_SIZE)

    self.signs = 
    {
        {
            text = "Welcome to Minecraft Creative Mode!\n\nThis is a fun little server for building\ncool stuff! Claim plots to protect your\nbuilds and prevent others from editing\nthem. Unprotected builds are cleared\ndaily, so be sure to protect them!\n\nUse the commands in chat!",
            position = Vector3(40000.945313, 2005.002197, 40014.585938),
            angle = Angle(-1.599378 + math.pi, 0.000000, 0.000000),
            color = Color.Red
        },
        {
            text = "Claiming Plots\n\nFirst use /plotlines to see where plots are and\nsee what is claimed. Claim a plot with\n/claimplot name. Now anything you build in the plot\nwill be saved. Plots include everything from the floor\nto the sky. Have fun!",
            position = Vector3(40014.675781, 2005.002686, 40018.917969),
            angle = Angle(-0.030802 + math.pi, 0.000000, 0.000000),
            color = Color.Blue
        },
        {
            text = "How do I get plot points?\n\nPlot points are used to claim plots. You can gain\nplot points by playing on the server. The more\nyou play, the more plots you can claim.\n\nCheck your plot points in the E menu.",
            position = Vector3(40019.136719, 2005.000610, 40005.792969),
            angle = Angle(1.574274 + math.pi, 0.000000, 0.000000),
            color = Color.Purple
        },
        {
            text = "Controls\n\nLeft click: destroy block\nRight click: place block\nScroll: change block\nE: open block selector menu\nF5: toggle first person view\nDouble tap jump: toggle fly mode\nShift: move faster in fly mode\nSpace: move up in fly mode\nCtrl: move down in fly mode",
            position = Vector3(40005.023438, 2005.501709, 40000.718750),
            angle = Angle(3.100353 + math.pi, 0.000000, 0.000000),
            color = Color.Yellow
        },
        {
            text = "Blocks destroyed: %s",
            position = Vector3(40012.011719, 2000.004610, 40014.011719),
            angle = Angle(math.pi, -math.pi / 2, 0),
            color = Color.Black,
            destroyed = true
        },
        {
            text = "Blocks placed: %s",
            position = Vector3(40011.785156, 2000.004099, 40004.347656),
            angle = Angle(math.pi, -math.pi / 2, 0),
            color = Color.Black,
            placed = true
        },
    }

    
    self.stats = {blocks_placed = 0, blocks_destroyed = 0}

    Events:Subscribe("GameRender", self, self.GameRenderOpaque)
    Network:Subscribe("SyncStats", self, self.SyncStats)

end

function SpawnAreaSigns:SyncStats(args)
    self.stats = args
end

Events:Subscribe("LocalPlayerChat", function(args)
    if args.text == "/pos" then
        print(LocalPlayer:GetPosition())
        print(Camera:GetAngle())
    end
end)

function SpawnAreaSigns:GameRenderOpaque(args)

    local cell = GetCell(LocalPlayer:GetPosition() + Vector3(0, 2, 0), CHUNK_SIZE)

    if cell.x ~= self.spawn_cell.x or cell.y ~= self.spawn_cell.y or cell.z ~= self.spawn_cell.z then return end

    for _, sign in pairs(self.signs) do
        local t = Transform3():Translate(sign.position):Rotate(sign.angle * Angle(0, math.pi, 0))
        Render:SetTransform(t)
        local text = sign.text

        if sign.destroyed then
            text = string.format(sign.text, self.stats.blocks_destroyed)
        elseif sign.placed then
            text = string.format(sign.text, self.stats.blocks_placed)
        end

        Render:DrawText(Vector3(), text, sign.color, 50, 0.01)
        Render:ResetTransform()
    end
end

SpawnAreaSigns = SpawnAreaSigns()