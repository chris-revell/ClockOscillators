#
#  CouplingStrength.jl
#  ClockOscillators
#
#  Created by Christopher Revell on 28/02/2023.
#
#
# 

module CouplingStrength

# Julia packages
using DrWatson
using FromFile
using UnPack

# Local modules
# @from "$(projectdir("src",".jl"))" using 

function couplingStrength(cell1,cell2,model,properties)
    @unpack λ, μ, ν, ξ, ω, dt = properties
    if cell1.type==
end

export couplingStrength

end
