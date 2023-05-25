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
using SparseArrays
using DifferentialEquations

# Local modules
@from "$(projectdir("src","CellAgents.jl"))" using CellAgents
@from "$(projectdir("src","PlottingFunctions.jl"))" using PlottingFunctions
@from "$(projectdir("src","CreateLaplacian.jl"))" using CreateLaplacian
@from "$(projectdir("src","CreateGrad.jl"))" using CreateGrad
@from "$(projectdir("src","DiffusionModel.jl"))" using DiffusionModel
    
function initialise(properties)
    
    @unpack nMacrophage,nFibroblast,speedMacrophage,speedFibroblast,extent,nX = properties

    dx = extent[1]/nX
    properties[:dx] = dx
    diffGrid = zeros(Float64,(nX+4)*(nX+4))
    properties[:∇²] = createLaplacian(nX, nX, dx)
    properties[:∇] = createGrad(nX, nX, dx)
    # properties[:xs] = [extent[1]-0.5*dx+i*dx for i=1:nX]
    properties[:diffGrid]   = diffGrid

    space2d = ContinuousSpace(extent,periodic=false)
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

    properties[:agents] = collect(allagents(model))
    prob = ODEProblem(ODEFunction(diffusionModel!), diffGrid, (0.0, Inf), properties)
    properties[:integrator] = init(prob, OrdinaryDiffEq.Tsit5(); advance_to_tstop = true)

    properties[:pairs] = Tuple{Int64,Int64}[]

    for iCell in allids(model)
        neighbours = collect(nearby_ids(model.agents[iCell], model, model.couplingThreshold))
        for jCell in neighbours 
            (min(iCell,jCell),max(iCell,jCell)) ∉ properties[:pairs] ? push!(properties[:pairs], (min(iCell,jCell),max(iCell,jCell))) : nothing
        end
    end

    return model

end

export initialise

end
