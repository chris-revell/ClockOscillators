#
#  Visualise.jl
#  ClockOscillators
#
#  Created by Christopher Revell on 24/03/2023.
#
#
# 

module Visualise

# Julia packages
using DrWatson
using FromFile
using UnPack
using Agents
using InteractiveDynamics
using CairoMakie
using GeometryBasics
using ColorSchemes

# Local modules
@from "$(projectdir("src","CellAgents.jl"))" using CellAgents
@from "$(projectdir("src","PlottingFunctions.jl"))" using PlottingFunctions

function visualise(agentsDF,modelDF,model)

    @unpack nX, nMacrophage, nFibroblast, tMax, dt = model.properties

    fig1 = Figure(figure_padding=0,resolution=(1000,1000))
    ax1 = CairoMakie.Axis(fig1[1,1],aspect=DataAspect())
    uInternal = Observable(zeros(nX,nX))
    points = Observable(Point2.([(0.0,0.0) for i=1:nMacrophage+nFibroblast]))
    clockPhaseColours = Observable(fill(ColorSchemes.romaO.colors[1],nMacrophage+nFibroblast))
    arrowsVec = Observable(Vec2.([(0.0,0.0) for i=1:nMacrophage+nFibroblast]))
    heatmap!(ax1,uInternal,colorrange=(0, 10.0),colormap=:inferno)
    scatter!(ax1,points,color=clockPhaseColours,markersize=4, markerspace=:data, marker=cellMarker.(agentsDF[1:nMacrophage+nFibroblast,:type]))
    arrows!(ax1,points,arrowsVec)
    hidedecorations!(ax1)
    hidespines!(ax1)
    ax1.title = "t=0.0"
    ax1.yreversed = true
    resize_to_layout!(fig1)
    tSteps = collect(1:ceil(Int64,tMax÷dt))
    record(fig1,"animation.mp4",tSteps; framerate=10) do i
        uInternal[] = transpose(reshape(modelDF[i,:diffGrid],(nX,nX)))
        uInternal[] = uInternal[]
        points[] = Point2.(agentsDF[(i-1)*(nMacrophage+nFibroblast)+1:i*(nMacrophage+nFibroblast),:pos])
        points[] = points[]
        clockPhaseColours[] = cellClockColour.(agentsDF[(i-1)*(nMacrophage+nFibroblast)+1:i*(nMacrophage+nFibroblast),:clockPhase])
        clockPhaseColours[] = clockPhaseColours[]
        arrowsVec[] = Vec2.(agentsDF[(i-1)*(nMacrophage+nFibroblast)+1:i*(nMacrophage+nFibroblast),:polarisation])
        arrowsVec[] = arrowsVec[]
    end

end

export visualise

end