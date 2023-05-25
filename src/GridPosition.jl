#
#  GridPosition.jl
#  ClockOscillators
#
#  Created by Christopher Revell on 04/04/2023.
#
#

module GridPosition

# Julia packages
using DrWatson
using FromFile

function gridPosition(pos,nX,dx)
    gridPositionX = floor(Int64, pos[1]/dx)+2
    gridPositionY = floor(Int64, pos[2]/dx)+2
    flattenedIndex = (gridPositionX-1)*nX+gridPositionY    
    return flattenedIndex
end

export gridPosition

end
