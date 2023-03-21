#
#  ModelStep.jl
#  ClockOscillators
#
#  Created by Christopher Revell on 21/03/2023.
#
#
# Update the state of the model at each timestep

module ModelStep

# Julia packages
using DrWatson
using FromFile
using UnPack
using Agents
using DifferentialEquations

function modelStep!(model)
    step!(model.integrator)
end

export modelStep!

end
