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
@from "$(projectdir("src","GridPosition.jl"))" using GridPosition

function agentStep!(cell, model)
    @unpack ∇, diffGrid, dx, nX, dt = model.properties
    # Update agent's internal clock based on system state
    updateClock(cell,model)
    
    if cell.type == :fibroblast
        # Sample background gradient
        flattenedIndex = gridPosition(cell.pos,nX,dx)
        neighbours = findnz(∇[flattenedIndex,:])[1]    
        polarisation = -1.0.*[diffGrid[neighbours[1]]-diffGrid[neighbours[4]], diffGrid[neighbours[2]]-diffGrid[neighbours[3]]]    
        cell.polarisation = Tuple(polarisation)
        direction = normalize(10.0.*polarisation.+rand(model.rng,2).-0.5)
        cell.vel = Tuple(direction.*cell.speed)
    else
        direction = normalize(rand(model.rng,2).-0.5)
        cell.vel = Tuple(direction.*cell.speed)
    end
    
    move_agent!(cell, model, dt)
    
    cell.neighbours = collect(nearby_ids(cell, model, model.couplingThreshold))
end

export agentStep!

end
