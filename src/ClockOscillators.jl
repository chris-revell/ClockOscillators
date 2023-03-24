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
    ω=2π, 
    λ=0.1, 
    μ=1.0, 
    ν=1.0, 
    ξ=0.1, 
    nX=100, 
)

    properties = @dict tMax couplingThreshold nMacrophage nFibroblast speedMacrophage speedFibroblast extent dt ω λ μ ν ξ nX
    model = initialise(properties)

    agentsDF, modelDF = run!(model,agentStep!,modelStep!,ceil(Int64,tMax÷dt); adata=[:pos], mdata=[:diffGrid])


    fig1 = Figure(figure_padding=0,resolution=(1000,1000))
    ax1 = CairoMakie.Axis(fig1[1,1],aspect=DataAspect())
    uInternal = Observable(zeros(nX,nX))
    points = Observable(Point2.([(0.0,0.0) for i=1:nMacrophage+nFibroblast]))
    heatmap!(ax1,uInternal,colorrange=(0, 10.0),colormap=:inferno)
    scatter!(ax1,points,color=:red)
    hidedecorations!(ax1)
    hidespines!(ax1)
    ax1.title = "t=0.0"
    ax1.yreversed = true
    resize_to_layout!(fig1)
    tSteps = collect(1:ceil(Int64,tMax÷dt))
    record(fig1,"diff.mp4",tSteps; framerate=10) do i
        # empty!(ax1)
        uInternal[] = transpose(reshape(modelDF[i,:diffGrid],(nX,nX)))
        uInternal[] = uInternal[]
        points[] = Point2.(agentsDF[(i-1)*(nMacrophage+nFibroblast)+1:i*(nMacrophage+nFibroblast),:pos])
        points[] = points[]
        # display(points[])
    end

    abmvideo("cells.mp4", model, agentStep!; am=cellMarker, as=30.0, ac=cellClockColour, framerate=30, frames=Int64(tMax/dt), title="Cells")

    return agentsDF, modelDF
end

export clockOscillators

end


    # abmvideo("cells.mp4", model, agentStep!; am=cellMarker, as=30.0, ac=cellClockColour, framerate=30, frames=Int64(tMax/dt), title="Cells")
