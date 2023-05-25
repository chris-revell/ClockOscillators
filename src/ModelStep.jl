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
    DifferentialEquations.step!(model.integrator,model.dt,true)
    u_modified!(model.integrator, true)
    model.diffGrid = copy(model.integrator.u)
end

export modelStep!

end
