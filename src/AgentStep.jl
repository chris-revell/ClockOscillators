#
#  AgentStep.jl
#  ClockOscillators
#
#  Created by Christopher Revell on 28/02/2023.
#
#
# 

module AgentStep

# Julia packages
using DrWatson
using FromFile
using UnPack
using Agents

# Local modules
@from "$(projectdir("src","CellAgents.jl"))" using CellAgents
@from "$(projectdir("src","UpdateClock.jl"))" using UpdateClock

function agentStep!(cell, model)
    updateClock(cell,model.dt)
    cell.vel = Tuple((rand(model.rng,2).-0.5).*cell.speed)
    # Move bird according to new velocity and speed
    move_agent!(cell, model, model.dt)
end

export agentStep!

end
