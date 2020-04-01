function GetManhattanDistance(cell1, cell2)

    return 
        math.abs(cell2.x - cell1.x) +
        math.abs(cell2.y - cell1.y) +
        math.abs(cell2.z - cell1.z)

end