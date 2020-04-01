class 'sClaimPoints'

function sClaimPoints:__init()

    SQL:Execute("CREATE TABLE IF NOT EXISTS player_data (steam_id VARCHER(20) PRIMARY KEY, claim_points INTEGER, exp INTEGER, blocks_placed INTEGER, blocks_destroyed INTEGER)")

    self.DEFAULT_CLAIM_POINTS = 1 -- Starting claim points that everyone gets when they join

    Events:Subscribe("TimeChange", self, self.TimeChange)

    Events:Subscribe("PlayerJoin", self, self.PlayerJoin)
    Events:Subscribe("PlayerQuit", self, self.PlayerQuit)

    Events:Subscribe("PlayerRemoveBlock", self, self.PlayerRemoveBlock)
    Events:Subscribe("PlayerPlaceBlock", self, self.PlayerPlaceBlock)
end

function sClaimPoints:TimeChange(args)

    if args.Minute % 2 ~= 0 then return end

    for player in Server:GetPlayers() do
        local data = player:GetValue("PlayerData")

        if data then

            if data.blocks_placed_this_session >= 50 then
                data.exp = data.exp + 1
                data.blocks_placed_this_session = 0

                if data.exp >= 5 then
                    data.exp = 0
                    data.claim_points = data.claim_points + 1
                end
            end

            player:SetNetworkValue("PlayerData", data)

            self:UpdatePlayer(player)

        end
    end

end

function sClaimPoints:PlayerQuit(args)
    self:UpdatePlayer(args.player)
end

function sClaimPoints:PlayerPlaceBlock(args)
    local data = args.player:GetValue("PlayerData")
    if not data then return end

    data.blocks_placed = data.blocks_placed + 1
    data.blocks_placed_this_session = data.blocks_placed_this_session + 1
    args.player:SetNetworkValue("PlayerData", data)
end

function sClaimPoints:PlayerRemoveBlock(args)
    local data = args.player:GetValue("PlayerData")
    if not data then return end

    data.blocks_destroyed = data.blocks_destroyed + 1
    args.player:SetNetworkValue("PlayerData", data)
end

function sClaimPoints:UpdatePlayer(player)

    local data = player:GetValue("PlayerData")
    if not data then return end

    local update = SQL:Command("UPDATE player_data SET claim_points = ?, exp = ?, blocks_placed = ?, blocks_destroyed = ? WHERE steam_id = (?)")
    update:Bind(1, data.claim_points)
    update:Bind(2, data.exp)
    update:Bind(3, data.blocks_placed)
    update:Bind(4, data.blocks_destroyed)
    update:Bind(5, tostring(player:GetSteamId()))
    update:Execute()
    
end

function sClaimPoints:PlayerJoin(args)
    
    local steamid = tostring(args.player:GetSteamId())

    local result = SQL:Query("SELECT * FROM player_data where steam_id = (?) LIMIT 1")
    result:Bind(1, tostring(args.player:GetSteamId()))
    result = result:Execute()

    if #result == 0 then

		local command = SQL:Command("INSERT INTO player_data (steam_id, claim_points, exp, blocks_placed, blocks_destroyed) VALUES (?, ?, ?, ?, ?)")
		command:Bind(1, steamid)
		command:Bind(2, self.DEFAULT_CLAIM_POINTS)
		command:Bind(3, 0)
		command:Bind(4, 0)
		command:Bind(5, 0)
        command:Execute()

        result = {}
        result[1] = 
        {
            claim_points = self.DEFAULT_CLAIM_POINTS,
            exp = 0,
            blocks_placed = 0,
            blocks_destroyed = 0
        }
        
    end


    args.player:SetNetworkValue("PlayerData", {
        claim_points = tonumber(result[1].claim_points),
        exp = tonumber(result[1].exp),
        blocks_placed = tonumber(result[1].blocks_placed),
        blocks_destroyed = tonumber(result[1].blocks_destroyed),
        blocks_placed_this_session = 0
    })

end

sClaimPoints = sClaimPoints()