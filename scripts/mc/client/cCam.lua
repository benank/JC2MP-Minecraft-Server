class 'Cam'

local CameraType = {First = 1, Third = 2}

function Cam:__init()

    self.camera_type = CameraType.Third

	self.fov = 0.7
	self.fov_zoom = 0.15
	self.current_fov = self.fov
	
	self.zoom_key = "Z"
	self.zoom_speed = 0.2
	
    self.zoomed = false
    
    self.camera_switch_key = VirtualKey.F5
	
	self.side = 1 --1 or -1 to switch sides
	
	self.inter = Camera:GetPosition()

	Events:Subscribe("CalcView", self, self.CalcView)
	Events:Subscribe("KeyDown", self, self.KeyDown)
	Events:Subscribe("KeyUp", self, self.KeyUp)
	Events:Subscribe("ModuleUnload", self, self.Unload)
	
	----------------------
	
	--[[self.obj = ClientStaticObject.Create({
		position = Camera:GetPosition(),
		angle = Angle(),
		model = " ",
		--collision = "gb090_lod1-g_col.pfx"
		collision = "gb090_lod1-g_col.pfx"
		})
	
	Events:Subscribe("Render", self, self.Render)-]]

end

--[[function Cam:Render(args)

	if self.obj then
	
		self.obj:SetPosition(Camera:GetPosition() + Camera:GetAngle() * Vector3(0,-1,0.7))
		self.obj:SetAngle(Camera:GetAngle())
	
	end
	
end--]]

function Cam:CalcView()

    if self.camera_type == CameraType.First then
        self:FirstPerson()
    elseif self.camera_type == CameraType.Third then
        self:ThirdPerson()
    end

end

function Cam:FirstPerson()

	local target_direction = Camera:GetAngle() * Vector3(0.35 * self.side,0,1)
	local player_pos = LocalPlayer:GetBonePosition("ragdoll_Head") - Camera:GetAngle() * Vector3(0, 0, 0.1)
	
	local target_pos = player_pos
	
    Camera:SetPosition(target_pos)

	if self.zoomed and self.current_fov > self.fov_zoom then
		local add = (self.current_fov - self.fov_zoom) * self.zoom_speed
		self.current_fov = self.current_fov - add
		if self.current_fov < self.fov_zoom then
			self.current_fov = self.fov_zoom
		end
	elseif not self.zoomed and self.current_fov < self.fov then
		local add = (self.current_fov - self.fov) * self.zoom_speed
		self.current_fov = self.current_fov - add
		if self.current_fov > self.fov then
			self.current_fov = self.fov
		end
	end
	
	Camera:SetFOV(self.current_fov)

end

function Cam:ThirdPerson()

	--[[local target_direction = Camera:GetAngle() * Vector3(0.35 * self.side,0,1)
	local player_pos = LocalPlayer:GetBonePosition("ragdoll_Spine") + Vector3(0,0.5,0)
    
    local camera_distance = 2

	local target_pos = player_pos + target_direction * camera_distance
	local ray = Physics:Raycast(player_pos, target_direction, 0, camera_distance)
	if ray.distance < camera_distance then
		target_pos = target_pos - target_direction * (camera_distance - ray.distance * 1.1)
	end
	
	
	Camera:SetPosition(target_pos)]]
	
	if self.zoomed and self.current_fov > self.fov_zoom then
		local add = (self.current_fov - self.fov_zoom) * self.zoom_speed
		self.current_fov = self.current_fov - add
		if self.current_fov < self.fov_zoom then
			self.current_fov = self.fov_zoom
		end
	elseif not self.zoomed and self.current_fov < self.fov then
		local add = (self.current_fov - self.fov) * self.zoom_speed
		self.current_fov = self.current_fov - add
		if self.current_fov > self.fov then
			self.current_fov = self.fov
		end
	end
	
	Camera:SetFOV(self.current_fov)

end

function Cam:KeyDown(args)

	if args.key == string.byte(self.zoom_key) and not self.zoomed then
		self.zoomed = not self.zoomed
	end
	
end

function Cam:KeyUp(args)

	if args.key == string.byte(self.zoom_key) and self.zoomed then
		self.zoomed = not self.zoomed
    elseif args.key == self.camera_switch_key then
        if self.camera_type == CameraType.First then
            self.camera_type = CameraType.Third
        else
            self.camera_type = CameraType.First
        end
    end
	
end

function Cam:Unload()

	Camera:SetFOV(1)
	if IsValid(self.obj) then self.obj:Remove() end
	
end

Cam = Cam()