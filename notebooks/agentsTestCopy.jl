using Agents, LinearAlgebra

LJ(r,σ,ϵ) = 24*ϵ*(σ^6/r^7 - 2*σ^12/r^13)

@agent Cell ContinuousAgent{2} begin
    separation::Float64
end

function initialize_model(; n_cells=100, separation=4.0, extent=(100, 100))
    space2d = ContinuousSpace(extent; spacing=separation)
    model = ABM(Cell, space2d, scheduler=Schedulers.Randomly())
    for _ in 1:n_cells
        vel = Tuple(rand(model.rng, 2) * 2 .- 1)
        add_agent!(model, vel, separation)
    end
    return model
end

function agent_step!(cell, model)
    # Obtain the ids of neighbors within the cell's visual distance
    neighbor_ids = nearby_ids(cell, model, cell.separation)
    N = 0    
    # Calculate behaviour properties based on neighbors
    for id in neighbor_ids
        neighborPos = model[id].pos
        separationVector = cell.pos - neighborPos        
        cell.vel = cell.vel + separationVector*LJ(norm(separationVector),cell.separation,1.0)/norm(separationVector)
    end
    # Move cell according to new velocity and speed
    move_agent!(cell, model, norm(cell.vel))
end

using InteractiveDynamics
using CairoMakie

# const cell_polygon = Polygon(Point2f[(-0.5, -0.5), (1, 0), (-0.5, 0.5)])
# function cell_marker(b::cell)
#     φ = atan(b.vel[2], b.vel[1]) #+ π/2 + π
#     scale(rotate2D(cell_polygon, φ), 2)
# end

model = initialize_model()
figure, = abmplot(model)

abmvideo(
    "flocking.mp4", model, agent_step!;
    am=cell_marker,
    framerate=20, frames=100,
    title="Flocking"
)