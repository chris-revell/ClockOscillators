#
#  ClockOscillators.jl
#  ClockOscillators
#
#  Created by Christopher Revell on 28/02/2023.
#
#
# 

module ClockOscillators

# Julia packages
using DrWatson
using FromFile
using UnPack
using Agents
using InteractiveDynamics
using CairoMakie
using GeometryBasics

# Local modules
@from "$(projectdir("src","CellAgents.jl"))" using CellAgents
@from "$(projectdir("src","AgentStep.jl"))" using AgentStep
@from "$(projectdir("src","ModelStep.jl"))" using ModelStep
@from "$(projectdir("src","UpdateClock.jl"))" using UpdateClock
@from "$(projectdir("src","Initialise.jl"))" using Initialise
@from "$(projectdir("src","PlottingFunctions.jl"))" using PlottingFunctions
@from "$(projectdir("src","Visualise2.jl"))" using Visualise2


function modelData(model)
    return [model.integrator.t, model.integrator.u]
end

function clockOscillators(;
    tMax=1.0, 
    couplingThreshold=10.0, 
    nMacrophage=50, 
    nFibroblast=50, 
    speedMacrophage=100.0, 
    speedFibroblast=100.0, 
    extent=(100, 100), 
    dt=0.01, 
    D = -100.0,
    ω=2π, 
    λ=0.1, 
    μ=1.0, 
    ν=1.0, 
    ξ=0.1, 
    nX=200, 
    nOutputs = 100,
)

    properties = @dict tMax couplingThreshold nMacrophage nFibroblast speedMacrophage speedFibroblast extent dt D ω λ μ ν ξ nX nOutputs
    
    nMax = ceil(Int64,tMax÷dt)

    outputInterval = tMax/nOutputs
    outputInterval<=dt ? throw("Output interval <= dt") : nothing
    properties[:outputInterval] = outputInterval

    model = initialise(properties)

    adata=[:pos, :clockPhase, :type, :neighbours]
    mdata=[:diffGrid]

    agentsDF = init_agent_dataframe(model, adata)
    modelDF = init_model_dataframe(model, mdata)

    s = [0]
    while s[1]<nMax
        if mod(s[1]*dt+0.0000001,outputInterval)<dt
            collect_agent_data!(agentsDF, model, adata, s[1])
            collect_model_data!(modelDF, model, mdata, s[1])
        end
        Agents.step!(model, agentStep!, modelStep!, 1)
        s[1] += 1
    end
    # return agentsDF, modelDF

    # agentsDF, modelDF = run!(model,agentStep!,modelStep!,ceil(Int64,tMax÷dt); adata=[:pos, :clockPhase, :type, :polarisation, :neighbours], mdata=[:diffGrid])

    visualise2(agentsDF,modelDF,model)

    return agentsDF, modelDF
end

export clockOscillators

end


    # abmvideo("cells.mp4", model, agentStep!; am=cellMarker, as=30.0, ac=cellClockColour, framerate=30, frames=Int64(tMax/dt), title="Cells")
