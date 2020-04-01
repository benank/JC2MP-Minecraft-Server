class 'cFlight'

function cFlight:__init()

    self.flight_enable_timer = Timer()
    self.flight_enable_window = 0.3
    self.trying_to_fly = false
    self.flying = false

    self.flight_speed = 500

    self.inputs = 
    {
        [Action.MoveForward] = Vector3(0, 0, -1),
        [Action.MoveBackward] = Vector3(0, 0, 1),
        [Action.MoveLeft] = Vector3(-1, 0, 0),
        [Action.MoveRight] = Vector3(1, 0, 0),
        [Action.Jump] = Vector3(0, 1, 0),
        [Action.Crouch] = Vector3(0, -1, 0)
    }

    self.change = Vector3()

    Events:Subscribe("LocalPlayerInput", self, self.LocalPlayerInput)
    Events:Subscribe("KeyUp", self, self.KeyUp)
    Events:Subscribe("Render", self, self.Render)

end

function cFlight:Render(args)

    if self.flight_enable_timer:GetSeconds() > self.flight_enable_window then
        self.trying_to_fly = false
    end

    if not self.flying then return end

    LocalPlayer:SetBaseState(AnimationState.SFall)

    local mod = self.flight_speed
    if Key:IsDown(VirtualKey.Shift) then
        mod = mod * 2
    end

    LocalPlayer:SetLinearVelocity(self.change * args.delta * mod)

    self.change = Vector3()

    local ray = Physics:Raycast(LocalPlayer:GetPosition(), Vector3.Down, 0, 0.1)

    if ray.distance < 0.1 then
        self.flying = false
    end

end

function cFlight:KeyUp(args)

    if args.key == VirtualKey.Space then

        if not self.trying_to_fly then
            self.flight_enable_timer:Restart()
            self.trying_to_fly = true
        elseif self.trying_to_fly and self.flight_enable_timer:GetSeconds() < self.flight_enable_window then
            self.trying_to_fly = false
            self.flying = not self.flying
        end

    end

end

function cFlight:LocalPlayerInput(args)

    if not self.flying then return end

    if self.inputs[args.input] then
        if args.input == Action.Jump or args.input == Action.Crouch then
            self.change = self.change + self.inputs[args.input]
        else
            self.change = self.change + Camera:GetAngle() * self.inputs[args.input]
        end
    end
end

cFlight = cFlight()