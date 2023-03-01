#
#  Initialise.jl
#  ClockOscillators
#
#  Created by Christopher Revell on 28/02/2023.
#
#
# 

module Initialise

# Julia packages
using DrWatson
using FromFile
using UnPack
using Agents

# Local modules
@from "$(projectdir("src","CellAgents.jl"))" using CellAgents
@from "$(projectdir("src","PlottingFunctions.jl"))" using PlottingFunctions
    
function initialise(properties)
    
    @unpack nMacrophage,nFibroblast,speedMacrophage,speedFibroblast,extent = properties
    
    space2d = ContinuousSpace(extent,periodic = false)
    model = ABM(Cell, space2d, properties=properties, scheduler=Schedulers.Randomly())
    # Add macrophages    
    for _ in 1:nMacrophage
        vel = Tuple(rand(model.rng, 2).-0.5)
        clockPhase = rand(model.rng)*2π
        add_agent_pos!(Macrophage(nextid(model),Tuple(rand(2).*extent),vel,speedMacrophage,clockPhase), model)
    end
    
    # Add fibroblasts
    for _ in 1:nFibroblast
        vel = Tuple(rand(model.rng, 2).-0.5)
        clockPhase = rand(model.rng)*2π
        add_agent_pos!(Fibroblast(nextid(model),Tuple(rand(2).*extent),vel,speedFibroblast,clockPhase), model)
    end

    return model

end

export initialise

end
