#
#  CreateGrad.jl
#  ClockOscillators
#
#  Created by Christopher Revell on 30/03/2023.
#
#
# 


module CreateGrad

# Import Julia packages
using LinearAlgebra
using SparseArrays

function createGrad(nX, nY, h)

    incidence = spzeros((nX+4)*(nY+4),(nX+4)*(nY+4))
    # List of index steps needed to reach neighbours in 5-point Von Neumann stencil
    dx = [ 0, 0, 1, -1]
    dy = [-1, 1, 0,  0]
    
    for x=1:(nX+4)
        for y=1:(nY+4)
            flattenedIndex = (x-1)*(nY+4)+y # Index of grid point (x,y) when 2D array is flattened to a 1D vector
            # Loop over all neighbours of (x,y)
            for i=1:length(dx)
                xNeighbour = x+dx[i] # Find (x,y) indices of neighbouring grid point
                yNeighbour = y+dy[i] # Find (x,y) indices of neighbouring grid point
                if xNeighbour<1 || xNeighbour>(nX+4) || yNeighbour<1 || yNeighbour>(nY+4)
                    #skip
                else 
                    flattenedIndexNeighbour = (xNeighbour-1)*(nY+4) + yNeighbour # Convert cartesian index of neighbour to corresponding index within flattened vector 
                    if -1∈[dx[i],dy[i]] 
                        incidence[flattenedIndex,flattenedIndexNeighbour] = -1
                    else
                        incidence[flattenedIndex,flattenedIndexNeighbour] = 1
                    end
                end 
            end
        end
    end

    ∇ = incidence./h

    return ∇

end

export createGrad

end
