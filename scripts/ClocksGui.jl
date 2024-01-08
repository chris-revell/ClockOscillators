#
#  ClocksGui.jl
#  ClockOscillators
#
#  Created by Christopher Revell on 27/10/2021.
#
#
# With components adapted from https://gist.github.com/Datseris/4b9d25a3ddb3936d3b83d3037f8188dd

# ω0  Sunlight phase rate of change /day
# ωF  Fibroblast phase intrinsic rate of change /day
# ωM  Macrophage phase intrinsic rate of change /day
# ϕF  Fibroblast preferred phase offset in coupling to macrophage
# ϕM  Macrophage preferred phase offset in coupling to fibroblast
# μ   Amplitude of fibroblast phase coupling to macrophage (effect of macrophage on fibroblast)
# ν   Amplitude of macrophage phase coupling to fibroblast (effect of fibroblast on macrophage)
# αF  Amplitude of fibroblast phase coupling to sunlight (effect of sunlight on fibroblast)
# αM  Amplitude of macrophage phase coupling to sunlight (effect of sunlight on fibroblast)
# ψF  Fibroblast preferred phase offset from sunlight
# ψM  Macrophage preferred phase offset from sunlight


using DynamicalSystems
using DifferentialEquations
using GLMakie
using DataStructures: CircularBuffer
using Images: load
using FileIO

δt = 0.005

# Function defining ODEs for model
function model!(du, u, p, t)
	ω0, ωF, ωM, ϕF, ϕM, μ, ν, αF, αM, ψF, ψM = p
	du[1] = ω0[]*π
	du[2] = ωF[]*π + μ[]*sin(u[3]-u[2]-ϕF[]*π) + αF[]*sin(u[1]-u[2]-ψF[]*π)
	du[3] = ωM[]*π + ν[]*sin(u[2]-u[3]-ϕM[]*π) + αM[]*sin(u[1]-u[3]-ψM[]*π)
end

# Function to convert phase states to x,y coordinates
function xycoords(state)
    x1 = sin(state[1])
    y1 = cos(state[1])
    x2 = sin(state[2])
    y2 = cos(state[2])
	x3 = sin(state[3])
	y3 = cos(state[3])
    return x1,x2,x3,y1,y2,y3
end

# Function to iterate system state
function progress_for_one_step!(integ)
    step!(integ)
    u = integ.u
    return u
end

# Function to update figure based on system iteration
function animstep!(integ, dots, hands, sunPhaseLine)
    u = progress_for_one_step!(integ)
	x1,x2,x3,y1,y2,y3 = xycoords(u)
    dots[] = [Point2f(x1, y1), Point2f(x2, y2), Point2f(x3, y3)]
	hands[] = [Point2f(x1, y1), Point2f(0,0), Point2f(x2, y2), Point2f(0, 0), Point2f(x3,y3)]

	sunPhaseLine[].-=Point2f(δt,0.0)
	fPhaseLine[].-=Point2f(δt,0.0)
	mPhaseLine[].-=Point2f(δt,0.0)
	sunPhaseLine[] = sunPhaseLine[]
	fPhaseLine[] = fPhaseLine[]
	mPhaseLine[] = mPhaseLine[]
	push!(sunPhaseLine[],Point2f(0.0,sin(u[1])))
	push!(fPhaseLine[],Point2f(0.0,sin(u[2])))
	push!(mPhaseLine[],Point2f(0.0,sin(u[3])))
	sunPhaseLine[] = sunPhaseLine[]
	fPhaseLine[] = fPhaseLine[]
	mPhaseLine[] = mPhaseLine[]
end

# Set up figure canvas
fig = Figure(resolution = (1000, 1100))
ga = fig[1,1] = GridLayout()
lim = 1.1 # Plot canvas limit

# Add phase plot
axPhase = Axis(ga[2,1],title="Circadian Rhythms",aspect=DataAspect())
xlims!(axPhase,(-lim,lim))
ylims!(axPhase,(-lim,lim))
lines!(axPhase,[Point2f(0.0,lim),Point2f(0.0,-lim)]; linestyle=:dash, alpha=0.5, color=:black)
lines!(axPhase,[Point2f(lim,0.0),Point2f(-lim,0.0)]; linestyle=:dash, alpha=0.5, color=:black)
hidedecorations!(axPhase)

# Add static system diagram to canvas
axDiagram = Axis(ga[2,2],title="System diagram",aspect=DataAspect())
image!(axDiagram,rotr90(load("supplementary/ClockOscillators.png")))
hidedecorations!(axDiagram)

# Set up phase line plot
axLine = Axis(ga[3,1])
xlims!(axLine,(-3.0,0.0))
ylims!(axLine,(-1.0,1.0))
nDays = 3.0
lineLength = round(Int64,nDays/δt) # length of plotted trajectory, in units of dt
sunPhaseLine = CircularBuffer{Point2f}(lineLength)
fPhaseLine = CircularBuffer{Point2f}(lineLength)
mPhaseLine = CircularBuffer{Point2f}(lineLength)
fill!(sunPhaseLine,Point2f(rand(),rand()))
fill!(fPhaseLine,Point2f(rand(),rand()))
fill!(mPhaseLine,Point2f(rand(),rand()))
for i=1:lineLength
	push!(sunPhaseLine,Point2f((1-lineLength+i)*0.005,0.0))
	push!(fPhaseLine,Point2f((1-lineLength+i)*0.005,0.0))
	push!(mPhaseLine,Point2f((1-lineLength+i)*0.005,0.0))
end
sunPhaseLine = Observable(sunPhaseLine)
fPhaseLine = Observable(fPhaseLine)
mPhaseLine = Observable(mPhaseLine)
lines!(axLine, sunPhaseLine; color=:red, linewidth=4, alpha=0.75)
lines!(axLine, fPhaseLine; color=:green, linewidth=4, alpha=0.75)
lines!(axLine, mPhaseLine; color=:blue, linewidth=4, alpha=0.75)



# Set up parameter sliders
lsgrid = SliderGrid(
		ga[3, 2],
        (label="ω0" , range=0:0.1:2, startvalue=2.0, format="{:.1f}π"),
        (label="ωF" , range=0:0.1:2, startvalue=2.0, format="{:.1f}π"),
        (label="ωM" , range=0:0.1:2, startvalue=2.0, format="{:.1f}π"),
        (label="ϕF" , range=0:0.1:2, startvalue=0.0, format="{:.1f}π"),
        (label="ϕM" , range=0:0.1:2, startvalue=0.0, format="{:.1f}π"),
        (label="μ"  , range=0:0.1:10.0, startvalue=0.0, format="{:.1f}"),
        (label="ν"  , range=0:0.1:10.0, startvalue=0.0, format="{:.1f}"),
        (label="αF" , range=0:0.1:10.0, startvalue=0.0, format="{:.1f}"),
        (label="αM" , range=0:0.1:10.0, startvalue=0.0, format="{:.1f}"),
        (label="ψF" , range=0:0.1:2, startvalue=0.0, format="{:.1f}π"),
        (label="ψM" , range=0:0.1:2, startvalue=0.0, format="{:.1f}π"),
        width = 350,
        # tellheight=true,
    )

# Pull parameters from slider positions [ω0, ωF, ωM, ϕF, ϕM, μ, ν, αF, αM, ψF, ψM]
sliderobservables = lift([s.value for s in lsgrid.sliders]...) do values...
	[values...]
end

# Initial conditions
u0   = rand(3).*(2π) # Initial phases (Sunlight, fibroblast, macrophage)
# Plot initial conditions as a vector of observable points.
x1,x2,x3,y1,y2,y3 = xycoords(u0)
# 3 points: one for each cell type
dots = Observable([Point2f(x1, y1), Point2f(x2, y2), Point2f(x3, y3)])
# 3 lines corresponding to a clock hand for each cell type
hands= Observable([Point2f(x1, y1), Point2f(0,0), Point2f(x2, y2), Point2f(0, 0), Point2f(x3,y3)])
# Plot objects
lines!(axPhase, hands; linewidth = 4, color = :black)
scatter!(axPhase, dots; marker=[:star8,:circle,:circle],color=[:red,:green,:blue],markersize=48)

# Set up differential equation integrator
prob = ODEProblem(model!,u0,(0.0,Inf),[2.0,2.0,2.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0])

# Set up integrator for each iteration
integ = init(prob, Tsit5(), adaptive = false, dt = δt)

on(sliderobservables) do sliderVals
	integ.p .= sliderVals
end

# Add stop/start button to the top of the canvas
run = Button(ga[1,1:2]; label = "Start/Stop", tellwidth = false)
isrunning = Observable(false)
on(run.clicks) do clicks; isrunning[] = !isrunning[]; end
on(run.clicks) do clicks
    @async while isrunning[]
        isopen(fig.scene) || break # ensures computations stop if closed window
        animstep!(integ, dots, hands, sunPhaseLine)
        sleep(0.02) 
    end
end

display(fig)
