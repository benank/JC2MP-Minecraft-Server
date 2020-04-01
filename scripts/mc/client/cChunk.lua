class 'Chunk'

local CHUNK_UID = 0

local function GET_CHUNK_UID()
    CHUNK_UID = CHUNK_UID + 1
    return CHUNK_UID
end


function Chunk:__init(cell, owner_info)

    self.cell = cell
    self.position = GetPosFromCell(self.cell, CHUNK_SIZE)
    self.model = nil
    self.blocks = initial_blocks or {} -- All blocks in chunk
    self.CSO_ids = {} -- Blocks indexed by their cso ids
    self.num_vertices = 0
    self.uid = GET_CHUNK_UID()

    self.old_model = nil
    self.old_model_frames = 0

    self.chunk_vertices = ChunkVertices(self)

    self.owner_info = owner_info or {}

    self:GetOutline()

    self.sub = Events:Subscribe("ModuleUnload", self, self.Unload)

end

function Chunk:UpdateOwnerInfo(info)
    self.owner_info = info

    if self.owner_info.owner_id == tostring(LocalPlayer:GetSteamId()) then
        self.outline_model:SetColor(Color(0, 255, 0))
    else
        self.outline_model:SetColor(Color.Red)
    end

end

function Chunk:Render(args)

    if self.model and self.num_vertices > 0 then

		local t = Transform3()
		t:Translate(self.position)
        Render:SetTransform(t)

        if self.outline_model and ChunkManager and ChunkManager.plot_lines_enabled then
            self.outline_model:Draw()
        end

        if self.old_model then
            self.old_model:Draw()
            if self.old_model_frames > 0 then
                self.old_model_frames = self.old_model_frames - 1
            else
                self.old_model = nil
            end
        end

        self.model:Draw()
        Render:ResetTransform()


        if ChunkManager and ChunkManager.plot_lines_enabled then

            if self.owner_info.owner_id then
                -- Chunk has an owner, render it and name
                local pos = self.position + Vector3(CHUNK_SIZE / 2, CHUNK_SIZE / 2, CHUNK_SIZE / 2)
                t = Transform3():Translate(pos):Rotate(Camera:GetAngle() * Angle(0, -math.pi, 0))
                Render:SetTransform(t)
                Render:DrawText(
                    Vector3(-2, 0, 0), 
                    self.owner_info.name, Color.White, 50, 0.01)
                Render:DrawText(
                    Vector3(-2, 1, 0), 
                    self.owner_info.owner_name, Color.White, 30, 0.01)

                Render:ResetTransform()
            end

        end


    end

end

function Chunk:Remove(instant)
    local count = 0
    for _, block in pairs(self.blocks) do
        block:Remove(true)
        if count % 2 == 0 and not instant then
            Timer.Sleep(1)
        end
        count = count + 1
    end
    Events:Unsubscribe(self.sub)
    collectgarbage("collect")
end

function Chunk:Unload()
    self:Remove(true)
end

function Chunk:RemoveBlockById(id)
    local block = self.CSO_ids[id]

    if not block then return end
    self:RemoveBlock(block)
end

function Chunk:RemoveBlockByPos(pos)
    local block = self.blocks[PosToString(pos)]

    if not block then return end
    self:RemoveBlock(block)
end

function Chunk:RemoveBlock(block)
    local key = PosToString(block.position)

    self.CSO_ids[block.obj:GetId()] = nil
    self.blocks[key]:Remove()
    self.blocks[key] = nil

    self.chunk_vertices:RemoveBlock(block)
    
    self:Regenerate()
end

function Chunk:AddBlock(pos, type)
    if self.blocks[PosToString(pos)] then return end -- A block is already at this position

    local block = Block(pos, type, self)

    self.CSO_ids[block.obj:GetId()] = block
    self.blocks[PosToString(block.position)] = block

    self.chunk_vertices:AddBlock(block)

    self:Regenerate()
end

function Chunk:Regenerate()
    self:_Regenerate()
end

-- Rebuilds the chunk after an update
function Chunk:_Regenerate()

    local vertices = self.chunk_vertices.vertices
    self.num_vertices = count_table(self.chunk_vertices.vertices)

    if self.num_vertices > 0 then

        self.old_model = self.model
        self.old_model_frames = 10

        self.model = Model.Create(vertices)
        self.model:SetTexture(BLOCK_IMAGE)
        self.model:SetTopology(Topology.TriangleList)
    end

end

function Chunk:GetOutline()

    local size = CHUNK_SIZE * 0.999

	local vertices = {}
	local pos = Vector3.Backward * size + Vector3.Right * size + Vector3.Up * size + Vector3(0, 0.02, 0)
	table.insert(vertices, Vertex(pos))
	table.insert(vertices, Vertex(pos + Vector3.Forward * size))
	table.insert(vertices, Vertex(pos + Vector3.Forward * size))
	table.insert(vertices, Vertex(pos + Vector3.Forward * size + Vector3.Left * size))
	table.insert(vertices, Vertex(pos + Vector3.Left * size))
	table.insert(vertices, Vertex(pos + Vector3.Forward * size + Vector3.Left * size))
	table.insert(vertices, Vertex(pos))
	table.insert(vertices, Vertex(pos + Vector3.Left * size))
	
	pos = pos + Vector3.Up * size
	table.insert(vertices, Vertex(pos))
	table.insert(vertices, Vertex(pos + Vector3.Forward * size))
	table.insert(vertices, Vertex(pos + Vector3.Forward * size))
	table.insert(vertices, Vertex(pos + Vector3.Forward * size + Vector3.Left * size))
	table.insert(vertices, Vertex(pos + Vector3.Left * size))
	table.insert(vertices, Vertex(pos + Vector3.Forward * size + Vector3.Left * size))
	table.insert(vertices, Vertex(pos))
	table.insert(vertices, Vertex(pos + Vector3.Left * size))
	
	
	table.insert(vertices, Vertex(pos))
	table.insert(vertices, Vertex(pos + Vector3.Down * size))
	table.insert(vertices, Vertex(pos + Vector3.Forward * size))
	table.insert(vertices, Vertex(pos + Vector3.Forward * size + Vector3.Down * size))
	table.insert(vertices, Vertex(pos + Vector3.Left * size))
	table.insert(vertices, Vertex(pos + Vector3.Left * size + Vector3.Down * size))
	table.insert(vertices, Vertex(pos + Vector3.Left * size + Vector3.Forward * size))
	table.insert(vertices, Vertex(pos + Vector3.Left * size + Vector3.Forward * size + Vector3.Down * size))
	
	self.outline_model = Model.Create(vertices)
    self.outline_model:SetTopology(Topology.LineList)

    if self.owner_info.owner_id == nil then
        self.outline_model:SetColor(Color.White)
    elseif self.owner_info.owner_id == tostring(LocalPlayer:GetSteamId()) then
        self.outline_model:SetColor(Color(0, 255, 0))
    else
        self.outline_model:SetColor(Color.Red)
    end

end