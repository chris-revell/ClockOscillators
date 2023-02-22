using Agents
using LinearAlgebra
using InteractiveDynamics
using CairoMakie

@agent Fibroblast ContinuousAgent{2} begin
    type::Symbol
    speed::Float64
end

const v0 = (0.0, 0.0, 0.0) 
Macrophage(id, pos, speed) = Animal(id, pos, v0, :macrophage, speed)
Fibroblast(id, pos, speed) = Animal(id, pos, v0, :fibroblast, speed)


function initialize_model(;nCells=100, speed=1.0, extent=(100, 100))
    space2d = ContinuousSpace(extent)
    model = ABM(Cell, space2d, scheduler=Schedulers.Randomly())
    for _ in 1:nCells
        vel = Tuple(rand(model.rng, 2).-0.5)
        add_agent!(
            model,
            vel,
            speed,
        )
    end
    return model
end

function agent_step!(cell, model)
    # Obtain the ids of neighbors within the bird's visual distance
   
    cell.vel = Tuple(rand(model.rng,2).-0.5)
    # Move bird according to new velocity and speed
    move_agent!(cell, model, cell.speed)
end

model = initialize_model()

# figure, = abmplot(model)#; am=bird_marker)

abmvideo("cells.mp4", model, agent_step!; framerate=20, frames=100, title="Cells")