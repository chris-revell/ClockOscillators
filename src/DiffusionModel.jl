#
#  DiffusionModel.jl
#  ClockOscillators
#
#  Created by Christopher Revell on 21/03/2023.
#
#
# Update the state of an agent at each timestep

module DiffusionModel

# Julia packages
using DrWatson
using FromFile
using UnPack
using LinearAlgebra

# Local modules
@from "$(projectdir("src","GridPosition.jl"))" using GridPosition

function diffusionModel!(du, u, p, t)
    @unpack ∇², nX, agents, dx = p
    du .= -100.0.*∇²*u

    for cell in [cell for cell in agents if cell.type==:macrophage]
        flattenedIndex = gridPosition(cell.pos,nX,dx)
        du[flattenedIndex] += 1000.0
    end 

    du .-= u.^2

    return du
end

export diffusionModel!

end
