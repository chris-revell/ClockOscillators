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

# Local modules
@from "$(projectdir("src","CellAgents.jl"))" using CellAgents
@from "$(projectdir("src","UpdateClock.jl"))" using UpdateClock

function agentStep!(cell, model)
    @unpack dt = model.properties
    # Update agent's internal clock based on system state
    updateClock(cell,model)
    # Select a random direction for 
    cell.vel = Tuple(normalize(rand(model.rng,2).-0.5).*cell.speed)
    move_agent!(cell, model, dt)
end

export agentStep!

end
