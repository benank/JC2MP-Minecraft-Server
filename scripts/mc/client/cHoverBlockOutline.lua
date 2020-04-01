class 'HoverBlockOutline'

function HoverBlockOutline:__init()

    self:CreateModel()

    Events:Subscribe("GameRenderOpaque2", self, self.Render)
end

function HoverBlockOutline:CreateModel()

	local vertices = {}
	local pos = Vector3.Backward * 0.5 + Vector3.Right * 0.5
	table.insert(vertices, Vertex(pos))
	table.insert(vertices, Vertex(pos + Vector3.Forward))
	table.insert(vertices, Vertex(pos + Vector3.Forward))
	table.insert(vertices, Vertex(pos + Vector3.Forward + Vector3.Left))
	table.insert(vertices, Vertex(pos + Vector3.Left))
	table.insert(vertices, Vertex(pos + Vector3.Forward + Vector3.Left))
	table.insert(vertices, Vertex(pos))
	table.insert(vertices, Vertex(pos + Vector3.Left))
	
	pos = pos + Vector3.Up
	table.insert(vertices, Vertex(pos))
	table.insert(vertices, Vertex(pos + Vector3.Forward))
	table.insert(vertices, Vertex(pos + Vector3.Forward))
	table.insert(vertices, Vertex(pos + Vector3.Forward + Vector3.Left))
	table.insert(vertices, Vertex(pos + Vector3.Left))
	table.insert(vertices, Vertex(pos + Vector3.Forward + Vector3.Left))
	table.insert(vertices, Vertex(pos))
	table.insert(vertices, Vertex(pos + Vector3.Left))
	
	
	table.insert(vertices, Vertex(pos))
	table.insert(vertices, Vertex(pos + Vector3.Down))
	table.insert(vertices, Vertex(pos + Vector3.Forward))
	table.insert(vertices, Vertex(pos + Vector3.Forward + Vector3.Down))
	table.insert(vertices, Vertex(pos + Vector3.Left))
	table.insert(vertices, Vertex(pos + Vector3.Left + Vector3.Down))
	table.insert(vertices, Vertex(pos + Vector3.Left + Vector3.Forward))
	table.insert(vertices, Vertex(pos + Vector3.Left + Vector3.Forward + Vector3.Down))
	
	self.model = Model.Create(vertices)
    self.model:SetTopology(Topology.LineList)
    self.model:SetColor(Color.Black)
	
end

function HoverBlockOutline:Render(args)

    if not self.model then return end
    if not ChunkManager or not ChunkManager.adjacent_chunks then return end

    local ray = Physics:Raycast(Camera:GetPosition(), Camera:GetAngle() * Vector3.Forward, 0, BLOCK_INTERACT_RANGE)

    if not ray.entity or ray.entity.__type ~= "ClientStaticObject" then return end
    self.look_entity = nil

    for _, cell in pairs(ChunkManager.adjacent_chunks) do
        if ChunkManager.chunks[cell.x] and ChunkManager.chunks[cell.x][cell.y] and ChunkManager.chunks[cell.x][cell.y][cell.z] then
            local chunk = ChunkManager.chunks[cell.x][cell.y][cell.z]

            if chunk.CSO_ids[ray.entity:GetId()] then
                self.look_entity = ray.entity
                break
            end

        end
    end

    if IsValid(self.look_entity) then
        local t = Transform3():Translate(self.look_entity:GetPosition()):Scale(1.005)
        Render:SetTransform(t)
        self.model:Draw()
        Render:ResetTransform()
    end

end

HoverBlockOutline = HoverBlockOutline()