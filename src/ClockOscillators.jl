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

# Local modules
@from "$(projectdir("src","CellAgents.jl"))" using CellAgents
@from "$(projectdir("src","AgentStep.jl"))" using AgentStep
@from "$(projectdir("src","UpdateClock.jl"))" using UpdateClock
@from "$(projectdir("src","Initialise.jl"))" using Initialise
@from "$(projectdir("src","PlottingFunctions.jl"))" using PlottingFunctions

function clockOscillators()
    
    model = initialise()
    
    abmvideo("cells.mp4", model, agentStep!; am=cellMarker, as=30.0, ac=cellClockColour, framerate=20, frames=1000, title="Cells")

end

export clockOscillators

end
