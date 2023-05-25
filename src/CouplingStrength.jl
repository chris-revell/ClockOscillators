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
using Agents

# Local modules
@from "$(projectdir("src","CellAgents.jl"))" using CellAgents

# return coupling strength for the effect of cell2 clock on cell1 clock 
function couplingStrength(cell1,cell2,properties)
    @unpack λ, μ, ν, ξ = properties
    if cell1.type==:fibroblast && cell2.type==:fibroblast
        return λ
    elseif cell1.type==:fibroblast && cell2.type==:macrophage
        return μ
    elseif cell1.type==:macrophage && cell2.type==:macrophage
        return ν
    elseif cell1.type==:macrophage && cell2.type==:fibroblast
        return ξ
    end
end

export couplingStrength

end
