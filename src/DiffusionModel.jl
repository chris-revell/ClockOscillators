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
    @unpack D, ∇², nX, agents, dx = p

    # Apply boundary conditions
    u[1:(nX+4):end] .= u[4:(nX+4):end]
    u[2:(nX+4):end] .= u[3:(nX+4):end]
    u[nX+4:(nX+4):end] .= u[nX+1:(nX+4):end]
    u[nX+3:(nX+4):end] .= u[nX+2:(nX+4):end]
    u[1:nX+4] .= u[1+3*(nX+4):4*(nX+4)]
    u[1+nX+4:2*(nX+4)] .= u[1+2*(nX+4):3*(nX+4)]
    u[1+(nX+3)*(nX+4):(nX+4)*(nX+4)] .= u[1+(nX+1)*(nX+4):(nX+2)*(nX+4)]
    u[1+(nX+2)*(nX+4):(nX+3)*(nX+4)] .= u[1+nX*(nX+4):(nX+1)*(nX+4)]
    
    # Diffusion component of du (du .= -D.*∇²*u)
    mul!(du,∇²,u)
    du .*= D

    # Degradation component of du
    du .-= u.^2

    du[ceil(Int64,((nX+4)^2)/2+nX/2+2)] += 1000.0


    # Source component of du from macrophages
    # for cell in agents
    #     if cell.type==:macrophage
    #         flattenedIndex = gridPosition(cell.pos,nX+4,dx)
    #         du[flattenedIndex] += 1000.0
    #     end
    # end 

    return du
end

export diffusionModel!

end
