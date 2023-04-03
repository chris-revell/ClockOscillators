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

    incidence = spzeros(nX*nY,nX*nY)
    # List of index steps needed to reach neighbours in 5-point Von Neumann stencil
    dx = [ 0, 0, 1, -1]
    dy = [-1, 1, 0,  0]
    for x=1:nX
        for y=1:nY
            flattenedIndex = (x-1)*nY+y # Index of grid point (x,y) when 2D array is flattened to a 1D vector
            # Loop over all neighbours of (x,y)
            for i=1:length(dx)
                xNeighbour = mod(nX+x+dx[i]-1,nX)+1                       # Find (x,y) indices of neighbouring grid point, introducing periodicity with arrayLoop
                yNeighbour = mod(nY+y+dy[i]-1,nY)+1                       # Find (x,y) indices of neighbouring grid point, introducing periodicity with arrayLoop
                flattenedIndexNeighbour = (xNeighbour-1)*nY + yNeighbour # Convert cartesian index of neighbour to corresponding index within flattened vector 
                if -1∈[dx[i],dy[i]] 
                    incidence[flattenedIndex,flattenedIndexNeighbour] = -1
                else
                    incidence[flattenedIndex,flattenedIndexNeighbour] = 1
                end
            end
        end
    end

    ∇ = incidence./h

    return ∇

end

export createGrad

end
