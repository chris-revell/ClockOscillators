#
#  AgentStep.jl
#  ClockOscillators
#
#  Created by Christopher Revell on 28/02/2023.
#
#
# Update the state of an agent at each timestep

module AgentStep

# Julia packages
using DrWatson
using FromFile
using UnPack
using Agents
using LinearAlgebra
using SparseArrays

# Local modules
@from "$(projectdir("src","CellAgents.jl"))" using CellAgents
@from "$(projectdir("src","UpdateClock.jl"))" using UpdateClock

function agentStep!(cell, model)
    @unpack ∇, diffGrid, dx, nX, dt = model.properties
    # Update agent's internal clock based on system state
    updateClock(cell,model)
    
    # Sample background gradient
    gridPositionX = mod((round(Int64, cell.pos[1]/dx)),nX)+1    
    gridPositionY = mod((round(Int64, cell.pos[2]/dx)),nX)+1    
    flattenedIndex = (gridPositionX-1)*nX+gridPositionY    
    neighbours = findnz(∇[flattenedIndex,:])[1]    
    polarisation = -1.0.*[diffGrid[neighbours[1]]-diffGrid[neighbours[4]], diffGrid[neighbours[2]]-diffGrid[neighbours[3]]]    
    cell.polarisation = Tuple(polarisation)
    direction = normalize(100.0.*polarisation.+rand(model.rng,2).-0.5)
    cell.vel = Tuple(direction.*cell.speed)
    
    move_agent!(cell, model, dt)
end

export agentStep!

end
