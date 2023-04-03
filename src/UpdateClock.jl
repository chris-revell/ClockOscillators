#
#  UpdateClock.jl
#  ClockOscillators
#
#  Created by Christopher Revell on 28/02/2023.
#
#
# 

module UpdateClock

# Julia packages
using DrWatson
using FromFile
using UnPack
using Agents

# Local modules
@from "$(projectdir("src","CellAgents.jl"))" using CellAgents
@from "$(projectdir("src","CouplingStrength.jl"))" using CouplingStrength

function updateClock(cell,model)
    @unpack couplingThreshold, dt, ω = model.properties
    neighborIDs = nearby_ids(cell, model, couplingThreshold)
    for n in neighborIDs
        cell.clockPhase = cell.clockPhase + couplingStrength(cell,model[n],model.properties)*sin(model[n].clockPhase-cell.clockPhase)*dt
    end
    cell.clockPhase = mod((cell.clockPhase + ω*dt),2π)
end

export updateClock

end
