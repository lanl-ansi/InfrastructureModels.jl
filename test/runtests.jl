using InfrastructureModels
import Memento
import JSON

import JuMP

import Ipopt
import ECOS
import Juniper
import Logging

const MOI = JuMP.MathOptInterface

ipopt_solver = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "print_level" => 0, "sb" => "yes")
ecos_solver = JuMP.optimizer_with_attributes(ECOS.Optimizer, "verbose" => 0)
juniper_solver = JuMP.optimizer_with_attributes(Juniper.Optimizer, "nl_solver" => ipopt_solver, "log_levels" => [])

import Random: seed!

using Test

# Suppress warnings during testing
InfrastructureModels.logger_config!("error")
Logging.disable_logging(Logging.Info)
Logging.disable_logging(Logging.Warn)

include("common.jl")

@testset "InfrastructureModels Tests" begin

include("data.jl")

include("base.jl")

include("constraint.jl")

include("relaxation_scheme.jl")

end
