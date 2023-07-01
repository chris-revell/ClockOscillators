#
#  Visualise2.jl
#  ClockOscillators
#
#  Created by Christopher Revell on 24/05/2023.
#
#
# 

module Visualise2

# Julia packages
using DrWatson
using FromFile
using UnPack
using Agents
using InteractiveDynamics
using CairoMakie
using GeometryBasics
using ColorSchemes
using Format

# Local modules
@from "$(projectdir("src","CellAgents.jl"))" using CellAgents
@from "$(projectdir("src","PlottingFunctions.jl"))" using PlottingFunctions

function visualise2(agentsDF,modelDF,model)

    @unpack nX, nMacrophage, nFibroblast, tMax, dt, dx, extent, nOutputs, outputInterval = model.properties

    fig1 = Figure(figure_padding=0,resolution=(1000,1000))
    ax1 = CairoMakie.Axis(fig1[1,1],aspect=DataAspect())
   
    mov = VideoStream(fig1;format="mp4", framerate=10)
   
    # Set x and y spatial values based on system "extent"
    xs = zeros(Float64,(nX+4)*(nX+4))
    ys = zeros(Float64,(nX+4)*(nX+4))
    gridValRange = collect(-3*dx/2.0:dx:extent[2]+3*dx/2)
    for i=1:nX+4
        xs[(i-1)*(nX+4)+1:i*(nX+4)] .= gridValRange
        ys[i:nX+4:(nX+4)*(nX+4)] .= gridValRange
    end
   
    points = fill(Point2(0.0,0.0),nMacrophage+nFibroblast)
    clockPhaseColours = fill(ColorSchemes.romaO.colors[1],nMacrophage+nFibroblast)
    for i=1:nOutputs
        empty!(ax1)
        ax1.title = "$(format(i*outputInterval,precision=2))"
        heatmap!(ax1,xs,ys,modelDF[i,:diffGrid],colorrange=(0, 2.0),colormap=:bilbao)
        xlims!(ax1,(0,extent[2]))
        ylims!(ax1,(0,extent[1]))
        points .= Point2.(last.(agentsDF[(i-1)*(nMacrophage+nFibroblast)+1:i*(nMacrophage+nFibroblast),:pos]),first.(agentsDF[(i-1)*(nMacrophage+nFibroblast)+1:i*(nMacrophage+nFibroblast),:pos]))
        clockPhaseColours .= cellClockColour.(agentsDF[(i-1)*(nMacrophage+nFibroblast)+1:i*(nMacrophage+nFibroblast),:clockPhase])
        scatter!(ax1,points,color=clockPhaseColours,markersize=5, markerspace=:data, marker=cellMarker.(agentsDF[1:nMacrophage+nFibroblast,:type]))

        for cell=1:nFibroblast+nMacrophage
            for pairedCell in agentsDF[(i-1)*(nMacrophage+nFibroblast)+cell,:neighbours]
                p1 = Point2(agentsDF[(i-1)*(nMacrophage+nFibroblast)+cell,:pos][2],agentsDF[(i-1)*(nMacrophage+nFibroblast)+cell,:pos][1])
                p2 = Point2(agentsDF[(i-1)*(nMacrophage+nFibroblast)+pairedCell,:pos][2],agentsDF[(i-1)*(nMacrophage+nFibroblast)+pairedCell,:pos][1])
                lines!(ax1,[p1,p2],linewidth=2,color=(:black,0.5))
            end
        end

        recordframe!(mov)
    end

    save("animation.mp4",mov)

end

export visualise2

end