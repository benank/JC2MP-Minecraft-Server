function GetCell(pos, cell_size)
    return {
        x = math.floor(pos.x / cell_size), 
        y = math.floor(pos.y / cell_size), 
        z = math.floor(pos.z / cell_size)}
end

function GetPosFromCell(cell, cell_size)
    return Vector3(cell.x * cell_size, cell.y * cell_size, cell.z * cell_size)
end

-- Returns a table containing objects with x and y of cells that are adjacent to the one given including the one given
function GetAdjacentCells(cell, range)

    range = range or 1
    local adjacent = {}

	for x = cell.x - range, cell.x + range do

        for y = cell.y - range, cell.y + range do

            for z = cell.z - range, cell.z + range do

                table.insert(adjacent, {x = x, y = y, z = z})

            end

        end

    end

    return adjacent
end

CHUNK_SIZE = 20
CELL_SIZES = {CHUNK_SIZE}
