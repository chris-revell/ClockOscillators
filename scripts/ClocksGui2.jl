#
#  ClocksGui2.jl
#  ClockOscillators
#
#  Created by Christopher Revell on 29/04/2024.
#
#

using OrdinaryDiffEq
using GLMakie
using DataStructures: CircularBuffer

δt = 0.005

# Function defining ODEs for model
function model!(du, u, p, t)
	ω, μ, ν = p
	du[1] = π + μ[]*sin(u[2]-u[1])
	du[2] = ω[]*π + ν[]*sin(u[1]-u[2])
end

# Function to update figure based on system iteration
function animstep!(integ, xys, dots, hands, phaseLine1, phaseLine2)
    step!(integ)
    xys .= [sin(integ.u[1]), cos(integ.u[1]), sin(integ.u[2]), cos(integ.u[2])]
    dots[] .= [Point{2,Float64}(xys[1:2]), Point{2,Float64}(xys[3:4])]
    dots[] = dots[]
    hands[] .= [Point{2,Float64}(xys[1:2]), Point{2,Float64}(0, 0), Point{2,Float64}(xys[3:4])]
    hands[] = hands[]
    phaseLine1[] .-= Point{2,Float64}(δt, 0.0)
    phaseLine2[] .-= Point{2,Float64}(δt, 0.0)
    push!(phaseLine1[], Point{2,Float64}(0.0, sin(integ.u[1])))
    push!(phaseLine2[], Point{2,Float64}(0.0, sin(integ.u[2])))
    phaseLine1[] = phaseLine1[]
    phaseLine2[] = phaseLine2[]
end

# Set up figure canvas
fig = Figure(size=(1500, 750), fontsize=32)

# Add phase plot
axPhase = Axis(fig[3,1],title="Circadian Rhythms",aspect=DataAspect())
lim = 1.1
xlims!(axPhase,(-lim,lim))
ylims!(axPhase,(-lim,lim))
lines!(axPhase,[Point{2,Float64}(0.0,lim),Point{2,Float64}(0.0,-lim)]; linestyle=:dash, alpha=0.5, color=:black)
lines!(axPhase,[Point{2,Float64}(lim,0.0),Point{2,Float64}(-lim,0.0)]; linestyle=:dash, alpha=0.5, color=:black)
hidedecorations!(axPhase)

# Set up phase line plot
axLine = Axis(fig[3,2])
xlims!(axLine,(-1.0,0.0))
ylims!(axLine,(-1.0,1.0))
nDays = 1.0
lineLength = round(Int64,nDays/δt) # length of plotted trajectory, in units of dt
phaseLine1 = CircularBuffer{Point{2,Float64}}(lineLength)
phaseLine2 = CircularBuffer{Point{2,Float64}}(lineLength)
for i=1:lineLength
	push!(phaseLine1,Point{2,Float64}((1-lineLength+i)*0.005,0.0))
	push!(phaseLine2,Point{2,Float64}((1-lineLength+i)*0.005,0.0))
end
phaseLine1 = Observable(phaseLine1)
phaseLine2 = Observable(phaseLine2)
lines!(axLine, phaseLine1; color=:green, linewidth=4, alpha=1.0)
lines!(axLine, phaseLine2; color=:blue, linewidth=4, alpha=1.0)


# Set up parameter sliders
lsgrid = SliderGrid(
		fig[2, :],
        (label="ω (blue intrinsic frequency / green intrinsic frequency)" , range=10.0:0.1:14.0, startvalue=10.0, format="{:.1f}"),
        (label="μ (dependence of green on blue)"  , range=0:0.1:100.0, startvalue=0.0, format="{:.1f}"),
        (label="ν (dependence of blue on green)"  , range=0:0.1:100.0, startvalue=0.0, format="{:.1f}"),
        width = 1400,
    )

# Pull parameters from slider positions [ω0, ωF, ωM, ϕF, ϕM, μ, ν, αF, αM, ψF, ψM]
sliderobservables = lift([s.value for s in lsgrid.sliders]...) do values...
	[values...]
end

# Initial conditions
u0   = rand(2).*(2π) # Initial phases (Sunlight, fibroblast, macrophage)

# Plot initial conditions as a vector of observable points.
xys = [sin(u0[1]), cos(u0[1]), sin(u0[2]), cos(u0[2])] # Convert phases to xy coordinates
dots = Observable([Point{2,Float64}(xys[1:2]...), Point{2,Float64}(xys[3:4]...)])
hands= Observable([Point{2,Float64}(xys[1:2]...), Point{2,Float64}(0,0), Point{2,Float64}(xys[3:4]...)])
lines!(axPhase, hands; linewidth = 4, color = :black)
scatter!(axPhase, dots; marker=[:circle,:circle],color=[:green,:blue],markersize=48)

# Set up differential equation integrator
prob = ODEProblem(model!,u0,(0.0,Inf),[10.0,0.0,0.0])

# Set up integrator for each iteration
integ = init(prob, Tsit5(), adaptive = false, dt = δt)

on(sliderobservables) do sliderVals
	integ.p .= sliderVals
end

# Add stop/start button to the top of the canvas
run = Button(fig[1,:]; label = "Start/Stop", tellwidth = false)
isrunning = Observable(false)
on(run.clicks) do clicks
    isrunning[] = !isrunning[]
end
on(run.clicks) do clicks
    @async while isrunning[]
        isopen(fig.scene) || break # ensures computations stop if closed window
        animstep!(integ, xys, dots, hands, phaseLine1, phaseLine2)
        sleep(0.02) 
    end
end

display(fig)
