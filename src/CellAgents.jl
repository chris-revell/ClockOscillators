#
#  CellAgents.jl
#  ClockOscillators
#
#  Created by Christopher Revell on 28/02/2023.
#
#
# 

module CellAgents

# Julia packages
using DrWatson
using FromFile
using Agents

@agent Cell ContinuousAgent{2} begin
    type::Symbol
    speed::Float64
    clockPhase::Float64
    polarisation::Tuple
end

Macrophage(id, pos, vel, speed, clockPhase) = Cell(id, pos, vel, :macrophage, speed, clockPhase,(0.0,0.0))
Fibroblast(id, pos, vel, speed, clockPhase) = Cell(id, pos, vel, :fibroblast, speed, clockPhase,(0.0,0.0))

export Cell, Macrophage, Fibroblast

end
