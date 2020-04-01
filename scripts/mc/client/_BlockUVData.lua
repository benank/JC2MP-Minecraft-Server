BLOCK_IMAGE = Image.Create(AssetLocation.Resource, "All_Textures_PNG_IMG")
BLOCK_IMAGE_SIZE = Vector2(10624, 128)
BLOCK_IMAGE:SetSize(BLOCK_IMAGE_SIZE)
NUM_BLOCK_IMAGES = BLOCK_IMAGE_SIZE.x / BLOCK_IMAGE_SIZE.y

BlockTexture = 
{
    Bedrock = 1,
    Bookshelf = 2,
    Brick = 3,
    CoalBlock = 4,
    CoalOre = 5,
    Cobblestone = 6,
    CraftingTableSide1 = 7,
    CraftingTableSide2 = 8,
    CraftingTableTop = 9,
    DiamondBlock = 10,
    DiamondOre = 11,
    Dirt = 12,
    IronDoorBottom = 13,
    IronDoorTop = 14,
    WoodDoorBottom = 15,
    WoodDoorTop = 16,
    EmeraldBlock = 17,
    EmeraldOre = 18,
    EnchantingTableBottom = 19,
    EnchantingTableSide = 20,
    EnchantingTableTop = 21,
    Furnace = 22,
    FurnaceLit = 23,
    FurnaceSide = 24,
    FurnaceTop = 25,
    Glass = 26,
    Glowstone = 27,
    GoldBlock = 28,
    GoldOre = 29,
    GrassBlockSide = 30,
    GrassSnowBlockSide = 31,
    GrassBlockTop = 32,
    Gravel = 33,
    Ice = 34,
    IronBlock = 35,
    IronOre = 36,
    LapisLazuliBlock = 37,
    LapisLazuliOre = 38,
    Leaves = 39,
    WoodSide = 40,
    WoodTop = 41,
    Netherrack = 42,
    Obsidian = 43,
    WoodenPlank = 44,
    RedstoneBlock = 45,
    RedstoneLamp = 46,
    RedstoneLampLit = 47,
    RedstoneOre = 48,
    Sand = 49,
    StoneBrick = 50,
    Stone = 51,
    SmoothStoneBrick = 52,
    SmoothStone = 53,
    TntBottom = 54,
    TntSide = 55,
    TntTop = 56,
    Torch = 57
}

NUM_BLOCK_IMAGES = count_table(BlockTexture)

-- Returns a table containing at least tex
function GetBlockUV(block_type)

    assert(BlockUV[block_type], "Failed to find BlockUV[block_type]: " .. tostring(block_type))

    local uvs = {}

    for uv_name, tex_uv in pairs(BlockUV[block_type]) do
        uvs[uv_name] = tex_uv
    end

    return uvs
end

-- Gets a texture uv from the big image using the index
function GetTexUV(tex_id)
    local uv1, uv2 = 
        Vector2(BLOCK_IMAGE_SIZE.x * ((tex_id - 1) / NUM_BLOCK_IMAGES), 0), 
        Vector2(BLOCK_IMAGE_SIZE.x * ((tex_id) / NUM_BLOCK_IMAGES), 1)
    
    uv1.x = uv1.x / BLOCK_IMAGE_SIZE.x
    uv2.x = uv2.x / BLOCK_IMAGE_SIZE.x

    local uva, uvb, uvc, uvd = 
        Vector2(uv2.x, uv2.y),
        Vector2(uv1.x, uv2.y),
        Vector2(uv2.x, uv1.y),
        Vector2(uv1.x, uv1.y)

    return {uva = uva, uvb = uvb, uvc = uvc, uvd = uvd}
end

function GetBlockCompleteMap(block_type, block_pos, base_pos, vertices, insert_pos)
    
    local uvs = GetBlockUV(block_type)

    local bottom_uv = uvs.bottom and uvs.bottom or uvs.tex
    local top_uv = uvs.top and uvs.top or uvs.tex
    local left_uv = uvs.left and uvs.left or uvs.tex
    local right_uv = uvs.right and uvs.right or uvs.tex
    local front_uv = uvs.front and uvs.front or uvs.tex
    local back_uv = uvs.back and uvs.back or uvs.tex

    local pos = block_pos - base_pos + Vector3.Backward

    insert_pos = insert_pos or #vertices + 1

    --local angle_cull = GetAngleCulling()
    
    -- Bottom
    --if angle_cull.bottom then
        table.insert(vertices, insert_pos, Vertex(pos, bottom_uv.uva))
        table.insert(vertices, insert_pos, Vertex(pos + Vector3.Right, bottom_uv.uvb))
        table.insert(vertices, insert_pos, Vertex(pos + Vector3.Forward, bottom_uv.uvc))
        table.insert(vertices, insert_pos, Vertex(pos + Vector3.Right, bottom_uv.uvb))
        table.insert(vertices, insert_pos, Vertex(pos + Vector3.Forward, bottom_uv.uvc))
        table.insert(vertices, insert_pos, Vertex(pos + Vector3.Forward + Vector3.Right, bottom_uv.uvd))
    --end
	
    -- Left
    --if angle_cull.left then
        table.insert(vertices, insert_pos, Vertex(pos, left_uv.uva))
        table.insert(vertices, insert_pos, Vertex(pos + Vector3.Up, left_uv.uvc))
        table.insert(vertices, insert_pos, Vertex(pos + Vector3.Forward + Vector3.Up, left_uv.uvd))
        table.insert(vertices, insert_pos, Vertex(pos, left_uv.uva))
        table.insert(vertices, insert_pos, Vertex(pos + Vector3.Forward, left_uv.uvb))
        table.insert(vertices, insert_pos, Vertex(pos + Vector3.Forward + Vector3.Up, left_uv.uvd))
    --end
	
	-- Right
    pos = pos + Vector3.Right
    --if angle_cull.right then
        table.insert(vertices, insert_pos, Vertex(pos, right_uv.uva))
        table.insert(vertices, insert_pos, Vertex(pos + Vector3.Up, right_uv.uvc))
        table.insert(vertices, insert_pos, Vertex(pos + Vector3.Forward + Vector3.Up, right_uv.uvd))
        table.insert(vertices, insert_pos, Vertex(pos, right_uv.uva))
        table.insert(vertices, insert_pos, Vertex(pos + Vector3.Forward, right_uv.uvb))
        table.insert(vertices, insert_pos, Vertex(pos + Vector3.Forward + Vector3.Up, right_uv.uvd))
    --end
	
    -- Back
    --if angle_cull.back then
        table.insert(vertices, insert_pos, Vertex(pos, back_uv.uva))
        table.insert(vertices, insert_pos, Vertex(pos + Vector3.Up, back_uv.uvc))
        table.insert(vertices, insert_pos, Vertex(pos + Vector3.Left + Vector3.Up, back_uv.uvd))
        table.insert(vertices, insert_pos, Vertex(pos, back_uv.uva))
        table.insert(vertices, insert_pos, Vertex(pos + Vector3.Left, back_uv.uvb))
        table.insert(vertices, insert_pos, Vertex(pos + Vector3.Left + Vector3.Up, back_uv.uvd))
    --end
	
	-- Front
    pos = pos + Vector3.Forward
    --if angle_cull.front then
        table.insert(vertices, insert_pos, Vertex(pos, front_uv.uva))
        table.insert(vertices, insert_pos, Vertex(pos + Vector3.Up, front_uv.uvc))
        table.insert(vertices, insert_pos, Vertex(pos + Vector3.Left + Vector3.Up, front_uv.uvd))
        table.insert(vertices, insert_pos, Vertex(pos, front_uv.uva))
        table.insert(vertices, insert_pos, Vertex(pos + Vector3.Left, front_uv.uvb))
        table.insert(vertices, insert_pos, Vertex(pos + Vector3.Left + Vector3.Up, front_uv.uvd))
    --end
    
	-- Top
    pos = pos + Vector3.Up + Vector3.Backward + Vector3.Left
    --if angle_cull.top then
        table.insert(vertices, insert_pos, Vertex(pos, top_uv.uva))
        table.insert(vertices, insert_pos, Vertex(pos + Vector3.Right, top_uv.uvb))
        table.insert(vertices, insert_pos, Vertex(pos + Vector3.Forward, top_uv.uvc))
        table.insert(vertices, insert_pos, Vertex(pos + Vector3.Right, top_uv.uvb))
        table.insert(vertices, insert_pos, Vertex(pos + Vector3.Forward, top_uv.uvc))
        table.insert(vertices, insert_pos, Vertex(pos + Vector3.Forward + Vector3.Right, top_uv.uvd))
    --end
    
end

function AngleToCullKey(angle)
    return string.format("%.4f,%.4f", angle.pitch, angle.yaw)
end

local angle_cull_cache = {}
local to_rad = 180 / math.pi

function GetAngleCulling()

    local cam_angle = Camera:GetAngle()
    local cull_key = AngleToCullKey(cam_angle)

    local yaw = cam_angle.yaw * to_rad
    local yaw_abs = math.abs(yaw)
    local pitch = cam_angle.pitch * to_rad

    if angle_cull_cache[cull_key] then
        return angle_cull_cache[cull_key]
    end

    local angle_cull = {
        front = yaw_abs > 60,
        back = yaw_abs < 120,
        right = yaw > -30 or yaw < -170,
        left = yaw < 10 or yaw > 150,
        top = pitch < 25,
        bottom = pitch > -25
    }

    angle_cull_cache[cull_key] = angle_cull

    return angle_cull
end

BlockUV = 
{
    [BlockType.Bedrock] = {tex = BlockTexture.Bedrock},
    [BlockType.Bookshelf] = {tex = BlockTexture.Bookshelf, top = BlockTexture.WoodenPlank, bottom = BlockTexture.WoodenPlank},
    [BlockType.Brick] = {tex = BlockTexture.Brick},
    [BlockType.CoalBlock] = {tex = BlockTexture.CoalBlock},
    [BlockType.CoalOre] = {tex = BlockTexture.CoalOre},
    [BlockType.Cobblestone] = {tex = BlockTexture.Cobblestone},
    [BlockType.CraftingTable] = {tex = BlockTexture.CraftingTableSide1, top = BlockTexture.CraftingTableTop, left = BlockTexture.CraftingTableSide2, right = BlockTexture.CraftingTableSide2, bottom = BlockTexture.WoodenPlank},
    [BlockType.DiamondBlock] = {tex = BlockTexture.DiamondBlock},
    [BlockType.DiamondOre] = {tex = BlockTexture.DiamondOre},
    [BlockType.Dirt] = {tex = BlockTexture.Dirt},
    [BlockType.IronDoor] = {tex = BlockTexture.IronDoorBottom},
    [BlockType.WoodDoor] = {tex = BlockTexture.WoodDoorBottom},
    [BlockType.EmeraldBlock] = {tex = BlockTexture.EmeraldBlock},
    [BlockType.EmeraldOre] = {tex = BlockTexture.EmeraldOre},
    [BlockType.EnchantingTable] = {tex = BlockTexture.EnchantingTableSide,  top = BlockTexture.CraftingTableTop, bottom = BlockTexture.EnchantingTableBottom},
    [BlockType.Furnace] = {tex = BlockTexture.FurnaceSide, front = BlockTexture.Furnace, top = BlockTexture.FurnaceTop, bottom = BlockTexture.FurnaceTop},
    [BlockType.Glass] = {tex = BlockTexture.Glass},
    [BlockType.Glowstone] = {tex = BlockTexture.Glowstone},
    [BlockType.GoldBlock] = {tex = BlockTexture.GoldBlock},
    [BlockType.GoldOre] = {tex = BlockTexture.GoldOre},
    [BlockType.GrassBlock] = {tex = BlockTexture.GrassBlockSide, top = BlockTexture.GrassBlockTop, bottom = BlockTexture.Dirt},
    [BlockType.Gravel] = {tex = BlockTexture.Gravel},
    [BlockType.Ice] = {tex = BlockTexture.Ice},
    [BlockType.IronBlock] = {tex = BlockTexture.IronBlock},
    [BlockType.IronOre] = {tex = BlockTexture.IronOre},
    [BlockType.LapisLazuliBlock] = {tex = BlockTexture.LapisLazuliBlock},
    [BlockType.LapisLazuliOre] = {tex = BlockTexture.LapisLazuliOre},
    [BlockType.Leaves] = {tex = BlockTexture.Leaves},
    [BlockType.Wood] = {tex = BlockTexture.WoodSide, top = BlockTexture.WoodTop, bottom = BlockTexture.WoodTop},
    [BlockType.Netherrack] = {tex = BlockTexture.Netherrack},
    [BlockType.Obsidian] = {tex = BlockTexture.Obsidian},
    [BlockType.WoodenPlank] = {tex = BlockTexture.WoodenPlank},
    [BlockType.RedstoneBlock] = {tex = BlockTexture.RedstoneBlock},
    [BlockType.RedstoneLamp] = {tex = BlockTexture.RedstoneLamp},
    [BlockType.RedstoneOre] = {tex = BlockTexture.RedstoneOre},
    [BlockType.Sand] = {tex = BlockTexture.Sand},
    [BlockType.StoneBrick] = {tex = BlockTexture.StoneBrick},
    [BlockType.Stone] = {tex = BlockTexture.Stone},
    [BlockType.SmoothStoneBrick] = {tex = BlockTexture.SmoothStoneBrick},
    [BlockType.SmoothStone] = {tex = BlockTexture.SmoothStone},
    [BlockType.Tnt] = {tex = BlockTexture.TntSide, bottom = BlockTexture.TntBottom, top = BlockTexture.TntTop},
    [BlockType.Torch] = {tex = BlockTexture.Torch}
}

BlockRenderOrder = 
{
    [BlockType.Bedrock] = 0,
    [BlockType.Bookshelf] = 0,
    [BlockType.Brick] = 0,
    [BlockType.CoalBlock] = 0,
    [BlockType.CoalOre] = 0,
    [BlockType.Cobblestone] = 0,
    [BlockType.CraftingTable] = 0,
    [BlockType.DiamondBlock] = 0,
    [BlockType.DiamondOre] = 0,
    [BlockType.Dirt] = 0,
    [BlockType.IronDoor] = 0,
    [BlockType.WoodDoor] = 0,
    [BlockType.EmeraldBlock] = 0,
    [BlockType.EmeraldOre] = 0,
    [BlockType.EnchantingTable] = 0,
    [BlockType.Furnace] = 0,
    [BlockType.Glass] = 3,
    [BlockType.Glowstone] = 0,
    [BlockType.GoldBlock] = 0,
    [BlockType.GoldOre] = 0,
    [BlockType.GrassBlock] = 0,
    [BlockType.Gravel] = 0,
    [BlockType.Ice] = 1,
    [BlockType.IronBlock] = 0,
    [BlockType.IronOre] = 0,
    [BlockType.LapisLazuliBlock] = 0,
    [BlockType.LapisLazuliOre] = 0,
    [BlockType.Leaves] = 2,
    [BlockType.Wood] = 0,
    [BlockType.Netherrack] = 0,
    [BlockType.Obsidian] = 0,
    [BlockType.WoodenPlank] = 0,
    [BlockType.RedstoneBlock] = 0,
    [BlockType.RedstoneLamp] = 0,
    [BlockType.RedstoneOre] = 0,
    [BlockType.Sand] = 0,
    [BlockType.StoneBrick] = 0,
    [BlockType.Stone] = 0,
    [BlockType.SmoothStoneBrick] = 0,
    [BlockType.SmoothStone] = 0,
    [BlockType.Tnt] = 0,
    [BlockType.Torch] = 2
}

BlockUVOriginal = deepcopy(BlockUV)

-- Precalculate and store all block uvs
for block_type, data in pairs(BlockUV) do
    for uv_name, tex_id in pairs(BlockUV[block_type]) do
        BlockUV[block_type][uv_name] = GetTexUV(tex_id)
    end
end
