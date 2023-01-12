using Agents, LinearAlgebra

@agent Cell ContinuousAgent{2} begin
    speed::Float64
    separation::Float64
    separate_factor::Float64
    visual_distance::Float64
end

function initialize_model(; n_cells=100, speed=1.0, separation=4.0, separate_factor=0.25, visual_distance=5.0, extent=(100, 100))
    space2d = ContinuousSpace(extent; spacing=visual_distance / 1.5)
    model = ABM(Cell, space2d, scheduler=Schedulers.Randomly())
    for _ in 1:n_cells
        vel = Tuple(rand(model.rng, 2) * 2 .- 1)
        add_agent!(model, speed, separation, separate_factor, visual_distance)
    end
    return model
end

function agent_step!(cell, model)
    # Obtain the ids of neighbors within the cell's visual distance
    neighbor_ids = nearby_ids(cell, model, cell.visual_distance)
    N = 0    
    # Calculate behaviour properties based on neighbors
    for id in neighbor_ids
        N += 1
        neighbor = model[id].pos
        if euclidean_distance(cell.pos, neighbor, model) < cell.separation
            # `separate` repels the cell away from neighboring cells
            separate = separate
        end
        # `match` computes the average trajectory of neighboring cells
    end
    N = max(N, 1)
    # Normalise results based on model input and neighbor count
    cohere = cohere ./ N .* cell.cohere_factor
    separate = separate ./ N .* cell.separate_factor
    match = match ./ N .* cell.match_factor
    # Compute velocity based on rules defined above
    cell.vel = (cell.vel .+ cohere .+ separate .+ match) ./ 2
    cell.vel = cell.vel ./ norm(cell.vel)
    # Move cell according to new velocity and speed
    move_agent!(cell, model, cell.speed)
end

using InteractiveDynamics
using CairoMakie

const cell_polygon = Polygon(Point2f[(-0.5, -0.5), (1, 0), (-0.5, 0.5)])
function cell_marker(b::cell)
    φ = atan(b.vel[2], b.vel[1]) #+ π/2 + π
    scale(rotate2D(cell_polygon, φ), 2)
end

model = initialize_model()
figure, = abmplot(model; am=cell_marker)

abmvideo(
    "flocking.mp4", model, agent_step!;
    am=cell_marker,
    framerate=20, frames=100,
    title="Flocking"
)