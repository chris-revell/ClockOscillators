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

# Local modules
# @from "$(projectdir("src",".jl"))" using 

function updateClock(cell,model,properties)
    @unpack λ, μ, ν, ξ, ω, dt = properties
    neighborIDs = nearby_ids(cell, model, model.couplingThreshold)
    if cell.type==:fibroblast
        for n in neighborIDs
            cell.clockPhase = cell.clockPhase + (ω + μ*sin(model[n].clockPhase-cell.clockPhase))*dt
            
    
    cell.clockPhase=(cell.clockPhase+model.dt)%2π

    du[2] = ωF[]*π + μ[]*sin(u[3]-u[2]-ϕF[]*π) + αF[]*sin(u[1]-u[2]-ψF[]*π)
    cell.clockPhase=(cell.clockPhase+model.dt)%2π
end

export updateClock

end
