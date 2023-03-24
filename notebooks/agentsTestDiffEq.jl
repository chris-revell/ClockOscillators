using Agents
using Distributions
using CairoMakie
# using OrdinaryDiffEq
using DifferentialEquations

mutable struct Fisher <: AbstractAgent
    id::Int
    competence::Int
    yearly_catch::Float64
end

function agent_step!(agent, model)
    if model.tick % 365 == 0
        agent.yearly_catch = rand(model.rng, Poisson(agent.competence))
    end
end

function dstock(model)
    # Only allow fishing if stocks are high enough
    # (monitored yearly, so this will return 0 364 days of the year)
    h = model.tick % 365 == 0 && model.stock > model.min_threshold ? sum(a.yearly_catch for a in allagents(model)) : 0.0

    model.stock * (1 - (model.stock / model.max_population)) - h
end

function model_step!(model)
    model.tick += 1
    model.stock += dstock(model)
end

# function initialise(;
#     stock = 400.0, # Initial population of fish (lets move to an equilibrium position)
#     max_population = 500.0, # Maximum value of fish stock
#     min_threshold = 60.0, # Regulate fishing if population drops below this value
#     nagents = 50,
# )
#     model = ABM(
#         Fisher;
#         properties = Dict(
#             :stock => stock,
#             :max_population => max_population,
#             :min_threshold => min_threshold,
#             :tick => 0, # Time keeper in units of days
#         ),
#     )
#     for _ in 1:nagents
#         add_agent!(model, floor(rand(model.rng, truncated(LogNormal(), 1, 6))), 0.0)
#     end
#     model
# end

# model = initialise()
# yearly(model, s) = s % 365 == 0
# _, results = run!(model, agent_step!, model_step!, 20 * 365; mdata = [:stock], when = yearly)

# f = Figure(resolution = (600, 400))
# ax =
#     f[1, 1] = Axis(
#         f,
#         xlabel = "Year",
#         ylabel = "Stock",
#         title = "Fishery Inventory",
#     )
# lines!(ax, results.stock, linewidth = 2, color = :blue)
# f




function agent_diffeq_step!(agent, model)
    agent.yearly_catch = rand(model.rng, Poisson(agent.competence))
end

function model_diffeq_step!(model)
    # We step 364 days with this call.
    OrdinaryDiffEq.step!(model.i, 364.0, true)
    # Only allow fishing if stocks are high enough
    # model.i.p[2] = model.i.u[1] > model.min_threshold ? sum(a.yearly_catch for a in allagents(model)) : 0.0
    # # Notify the integrator that conditions may be altered
    # OrdinaryDiffEq.u_modified!(model.i, true)
    # # Then apply our catch modifier
    # OrdinaryDiffEq.step!(model.i, 1.0, true)
    # Store yearly stock in the model for plotting
    model.stock = model.i.u[1]
    # And reset for the next year
    # model.i.p[2] = 0.0
    OrdinaryDiffEq.u_modified!(model.i, true)
end

function initialise_diffeq(;
    stock = 400.0, # Initial population of fish (lets move to an equilibrium position)
    max_population = 500.0, # Maximum value of fish stock
    min_threshold = 60.0, # Regulate fishing if population drops below this value
    nagents = 50,
)

    function fish_stock!(ds, s, p, t)
        max_population, h = p
        ds[1] = s[1] * (1 - (s[1] / max_population)) - h
    end
    prob = OrdinaryDiffEq.ODEProblem(fish_stock!, [stock], (0.0, Inf), [max_population, 0.0])
    integrator = OrdinaryDiffEq.init(prob, OrdinaryDiffEq.Tsit5(); advance_to_tstop = true)

    model = ABM(
        Fisher;
        properties = Dict(
            :stock => stock,
            :max_population => max_population,
            :min_threshold => min_threshold,
            :i => integrator, # The OrdinaryDiffEq integrator
        ),
    )
    for _ in 1:nagents
        add_agent!(model, floor(rand(model.rng, truncated(LogNormal(), 1, 6))), 0.0)
    end
    model
end

modeldeq = initialise_diffeq()
a, resultsdeq = run!(modeldeq, agent_diffeq_step!, model_diffeq_step!, 20; mdata = [:stock,:i])

f = Figure(resolution = (600, 400))
ax =
    f[1, 1] = Axis(
        f,
        xlabel = "Year",
        ylabel = "Stock",
        title = "Fishery Inventory",
    )
lines!(ax, resultsdeq.stock, linewidth = 2, color = :blue)
f