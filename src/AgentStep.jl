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
    @unpack dt = model.properties
    updateClock(cell,model)
    
    cell.vel = Tuple((rand(model.rng,2).-0.5).*cell.speed)
    move_agent!(cell, model, dt)
end

export agentStep!

end
