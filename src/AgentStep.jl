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
@from "$(projectdir("src","LennardJonesDerivative.jl"))" using LennardJonesDerivative

function agentStep!(cell, model)
    
    @unpack ∇, diffGrid, dx, nX, dt = model.properties
    # Update agent's internal clock based on system state
    updateClock(cell,model)
    
    if cell.type == :fibroblast
        # Sample background gradient
        flattenedIndex = gridPosition(cell.pos,nX+4,dx)
        neighboursGridPoints = findnz(∇[flattenedIndex,:])[1]    
        polarisation = -1.0.*[diffGrid[neighboursGridPoints[1]]-diffGrid[neighboursGridPoints[4]], diffGrid[neighboursGridPoints[2]]-diffGrid[neighboursGridPoints[3]]]    
        cell.polarisation = Tuple(polarisation)
        direction = normalize(10.0.*polarisation.+rand(model.rng,2).-0.5)
        cell.vel = Tuple(direction.*cell.speed)
    else
        direction = normalize(rand(model.rng,2).-0.5)
        cell.vel = Tuple(direction.*cell.speed)
    end

    for n in cell.neighbours
        sep = cell.pos.-getindex(model,n).pos
        display(dLJ(norm(sep),2.0).*sep./norm(sep))
        if norm(sep)<2.0
            display(dLJ(norm(sep),2.0).*sep./norm(sep))
            cell.vel = cell.vel #.+ dLJ(norm(sep),2.0).*sep./norm(sep)
        end
    end

    move_agent!(cell, model, dt)
    
    cell.neighbours = collect(nearby_ids(cell, model, model.couplingThreshold))
end

export agentStep!

end
