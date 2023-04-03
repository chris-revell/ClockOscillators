#
#  DiffusionModel.jl
#  ClockOscillators
#
#  Created by Christopher Revell on 21/03/2023.
#
#
# Update the state of an agent at each timestep

module DiffusionModel

# Julia packages
using DrWatson
using FromFile
using UnPack
using LinearAlgebra

# Local modules

function diffusionModel!(du, u, p, t)
    @unpack ∇², nX = p
    du .= -100.0.*∇²*u
    du[ceil(Int64,nX*(nX+1)/2)] += 1000.0
    # du .-= exp.(u)
    return du
end

export diffusionModel!

end
