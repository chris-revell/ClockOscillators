#
#  PlottingFunctions.jl
#  ClockOscillators
#
#  Created by Christopher Revell on 28/02/2023.
#
#
# 

module PlottingFunctions

# Julia packages
using DrWatson
using FromFile
using UnPack
using Agents
using ColorSchemes
using CairoMakie

# Local modules
@from "$(projectdir("src","CellAgents.jl"))" using CellAgents
    
function cellMarker(c::Cell)
    if c.type==:fibroblast
        return :diamond
    elseif c.type==:macrophage
        return :circle
    end
end

function cellClockColour(c::Cell)
    cyclePoint = ceil(Int64,(c.clockPhase/2π)*256)
    # return ColorSchemes.cyclic_wrwbw_40_90_c42_n256_s25.colors[cyclePoint]
    return ColorSchemes.romaO.colors[cyclePoint]
end

export cellMarker, cellClockColour

end
