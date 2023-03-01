using Agents
using LinearAlgebra
using InteractiveDynamics
using CairoMakie
using GeometryBasics
using ColorSchemes
using DifferentialEquations

nCells = 100

# Update clock 
# function updateClock(cell,model,properties)
#     @unpack μ, ν, ω, dt = properties
#     neighborIDs = nearby_ids(cell, model, model.couplingThreshold)
#     if cell.type==:fibroblast
#         for n in neighborIDs
#             cell.clockPhase = cell.clockPhase + (ω + μ*sin(model[n].clockPhase-cell.clockPhase))*dt
            
    
#     cell.clockPhase=(cell.clockPhase+model.dt)%2π

#     du[2] = ωF[]*π + μ[]*sin(u[3]-u[2]-ϕF[]*π) + αF[]*sin(u[1]-u[2]-ψF[]*π)
#     cell.clockPhase=(cell.clockPhase+model.dt)%2π
# end


@agent Cell ContinuousAgent{2} begin
    type::Symbol
    speed::Float64
    clockPhase::Float64
end

# const v0 = (0.0, 0.0, 0.0) 
# Macrophage(id, pos, speed) = Animal(id, pos, v0, :macrophage, speed)
Macrophage(id, pos, vel, speed, clockPhase) = Cell(id, pos, vel, :macrophage, speed, clockPhase)
# Fibroblast(id, pos, speed) = Animal(id, pos, v0, :fibroblast, speed)
Fibroblast(id, pos, vel, speed, clockPhase) = Cell(id, pos, vel, :fibroblast, speed, clockPhase)


function initialize_model(;
    couplingThreshold=10.0, 
    nMacrophage=50, 
    nFibroblast=50, 
    speedMacrophage=1.0, 
    speedFibroblast=1.0, 
    extent=(100, 100), 
    dt=0.1,
    ω=2π,
    μ=1.0,
    ν=1.0,
)
    space2d = ContinuousSpace(extent)
    properties = (couplingThreshold,nMacrophage,nFibroblast,speedMacrophage,speedFibroblast,extent,dt,ω,μ,ν)
    model = ABM(Cell, space2d, properties=properties, scheduler=Schedulers.Randomly())
    for _ in 1:nMacrophage
        vel = Tuple(rand(model.rng, 2).-0.5)
        clockPhase = rand(model.rng)*2π
        add_agent_pos!(Macrophage(nextid(model),Tuple(rand(2).*extent),vel,speedMacrophage,clockPhase), model)
    end
    for _ in 1:nFibroblast
        vel = Tuple(rand(model.rng, 2).-0.5)
        clockPhase = rand(model.rng)*2π
        add_agent_pos!(Fibroblast(nextid(model),Tuple(rand(2).*extent),vel,speedFibroblast,clockPhase), model)
    end
    return model
end

function agent_step!(cell, model)
    updateClock(cell,model.dt)
    cell.vel = Tuple((rand(model.rng,2).-0.5).*cell.speed)
    # Move bird according to new velocity and speed
    move_agent!(cell, model, model.dt)
end

model = initialize_model(speedMacrophage=5.0)

function cellMarker(c::Cell)
    if c.type==:fibroblast
        return :diamond
    elseif c.type==:macrophage
        return :circle
    end
end

function cellClockColour(c::Cell)
    cyclePoint = ceil(Int64,(c.clockPhase/2π)*256)
    return ColorSchemes.cyclic_wrwbw_40_90_c42_n256_s25.colors[cyclePoint]
    # return ColorSchemes.romaO.colors[cyclePoint]
    # return ColorSchemes.vikO.colors[cyclePoint]
end

abmvideo("cells.mp4", model, agent_step!; am=cellMarker, as=30.0, ac=cellClockColour, framerate=20, frames=1000, title="Cells")
