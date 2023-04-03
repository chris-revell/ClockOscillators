#
#  CreateLaplacian.jl
#  ClockOscillators
#
#  Created by Christopher Revell on 22/03/2023.
#
#
# In place Laplacian function
# In order to construct the linear operator and nonlinear function, we first define the Laplacian operator for this domain as $\nabla^2 = (\mathcal{J}-\mathcal{D})/h^2$ where $\mathcal{J}$ and $\mathcal{D}$ are the adjacency and degree matrices respectively using a Von Neumann neighbourhood 5-point stencil, and $h$ is the distance between adjacent grid points.  


module CreateLaplacian

# Import Julia packages
using LinearAlgebra
using SparseArrays

function createLaplacian(nX, nY, h)

    adj = spzeros(nX*nY,nX*nY)
    # List of index steps needed to reach neighbours in 5-point Von Neumann stencil
    dx = [ 0, 0, 1, -1]
    dy = [-1, 1, 0,  0]
    for x=1:nX
        for y=1:nY
            flattenedIndex = (x-1)*nY+y # Index of grid point (x,y) when 2D array is flattened to a 1D vector
            # Loop over all neighbours of (x,y)
            for i=1:length(dx)
                xNeighbour = mod(nX+x+dx[i]-1,nX)+1 #arrayLoop(x+dx[i],nX) # Find (x,y) indices of neighbouring grid point, introducing periodicity with arrayLoop
                yNeighbour = mod(nY+y+dy[i]-1,nY)+1 #arrayLoop(y+dy[i],nY) # Find (x,y) indices of neighbouring grid point, introducing periodicity with arrayLoop
                flattenedIndexNeighbour = (xNeighbour-1)*nY + yNeighbour # Convert cartesian index of neighbour to corresponding index within flattened vector 
                adj[flattenedIndex,flattenedIndexNeighbour] = 1 # Set corresponding component of adj to 1, indicating adjacency in 2D of grid points corresponding to flattenedIndex and flattenedIndexNeighbour
            end
        end
    end

    degree = spdiagm(0=>sum(adj, dims=2)[:,1]) # degree matrix is a diagonal matrix formed by the sum of each row in the adjacency matrix (should be 4 for all rows in a periodic system)
    ∇² = (degree-adj)./h^2                     # Laplacian matrix = (Adjacency matrix - Degree matrix)/grid spacing^2

    return ∇²

end

export createLaplacian

end
