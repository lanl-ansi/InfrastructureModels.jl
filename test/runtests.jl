using InfrastructureModels
import Memento
import JSON

import JuMP

import Ipopt
import ECOS
import Juniper

import MathOptInterface
const MOI = MathOptInterface

ipopt_solver = JuMP.with_optimizer(Ipopt.Optimizer, print_level=0)
ecos_solver = JuMP.with_optimizer(ECOS.Optimizer, verbose=0)
juniper_solver = JuMP.with_optimizer(Juniper.Optimizer, nl_solver=ipopt_solver, log_levels=[])  # MOI compatibility

import Random: seed!

using Test

# Suppress warnings during testing.
Memento.setlevel!(Memento.getlogger(InfrastructureModels), "error")

include("common.jl")

@testset "InfrastructureModels Tests" begin

include("base.jl")

include("data.jl")

include("relaxation_scheme.jl")

end