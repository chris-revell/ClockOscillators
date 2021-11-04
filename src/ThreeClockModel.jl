#
#  ThreeClockModel.jl
#  ClockOscillators
#
#  Created by Christopher Revell on 04/11/2021.
#
#

module ThreeClockModel

# Function defining ODEs for model
function model!(du, u, p, t)
	ω0, ωF, ωM, ϕF, ϕM, μ, ν, αF, αM, ψF, ψM = p
	du[1] = ω0[]*π
	du[2] = ωF[]*π + μ[]*sin(u[3]-u[2]-ϕF[]*π) + αF[]*sin(u[1]-u[2]-ψF[]*π)
	du[3] = ωM[]*π + ν[]*sin(u[2]-u[3]-ϕM[]*π) + αM[]*sin(u[1]-u[3]-ψM[]*π)
end

export model!

end
