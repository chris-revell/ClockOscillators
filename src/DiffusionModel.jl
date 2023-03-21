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
    @unpack ∇² = p
    du .= -∇²*u
end

export diffusionModel!

end
