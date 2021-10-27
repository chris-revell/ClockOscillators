using DifferentialEquations
using Plots;gr()

function model!(du, u, p, t)
	ω0, ωF, ωM, ϕF, ϕM, μ, ν, αF, αM, ψF, ψM = p
	du[1] = ω0
	du[2] = ωF + μ*sin(u[3]-u[2]-ϕF) + αF*sin(u[1]-u[2]-ψF)
	du[3] = ωM + ν*sin(u[2]-u[3]-ϕM) + αM*sin(u[1]-u[3]-ψM)
end

θ  = rand(3).%(2π) # Initial phases (Sunlight, fibroblast, macrophage)
tMax = 10.0 	   # Total time
ω0 = 2π            # Sunlight phase rate of change /day
ωF = 2π            # Fibroblast phase intrinsic rate of change /day
ωM = 2π            # Macrophage phase intrinsic rate of change /day
ϕF = 3π/5          # Fibroblast phase offset in coupling to macrophage
ϕM = 2π/5 		   # Macrophage phase offset in coupling to fibroblast
μ  = 1.0           # Amplitude of fibroblast phase coupling to macrophage
ν  = 0.0           # Amplitude of macrophage phase coupling to fibroblast
αF = 10.0          # Amplitude of fibroblast phase coupling to sunlight
αM = 10.0          # Amplitude of macrophage phase coupling to sunlight
ψF = π/8           # Fibroblast phase offset from sunlight
ψM = π/4          # Macrophage phase offset from sunlight
p = [ω0, ωF, ωM, ϕF, ϕM, μ, ν, αF, αM, ψF, ψM]

prob = ODEProblem(model!,θ,(0.0,tMax),p)
sol = solve(prob, Tsit5(),saveat=0.01)

u1s = [(θ[1]%2π)-π for θ in sol.u]
u2s = [(θ[2]%2π)-π for θ in sol.u]
u3s = [(θ[3]%2π)-π for θ in sol.u]

#plt = Figure()
#ax = Axis(plt)
plot(sol.t,u1s)
plot!(sol.t,u2s)
plot!(sol.t,u3s)
#display(plt)

# anim = @animate for u in sol.u
# 	scatter(sin.(u),cos.(u),xlims=(-1.1,1.1),ylims=(-1.1,1.1),aspect_ratio=:equal,marker=[:star8,:circle,:circle],color=[:red,:green,:blue],ms=10,series_annotations=["Light","Fib","Mac"],legend=:none)
# end
# gif(anim,"test.gif",fps=3)
