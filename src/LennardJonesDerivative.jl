#
#  LennardJonesDerivative.jl
#  ClockOscillators
#
#  Created by Christopher Revell on 25/05/2023.
#
#
# 

module LennardJonesDerivative

# Julia packages
using LinearAlgebra

dLJ(r,σ) = 4.0*0.0001*(6*σ/(r^7) - 12*σ/(r^13))

export dLJ

end
