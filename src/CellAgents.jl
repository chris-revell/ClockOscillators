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
end

Macrophage(id, pos, vel, speed, clockPhase) = Cell(id, pos, vel, :macrophage, speed, clockPhase)
Fibroblast(id, pos, vel, speed, clockPhase) = Cell(id, pos, vel, :fibroblast, speed, clockPhase)

export Cell, Macrophage, Fibroblast

end
