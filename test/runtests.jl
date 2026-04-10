using InfrastructureModels
using Test

import ECOS
import Ipopt
import JSON
import JuMP
import Juniper
import Random: seed!

# Suppress warnings during testing
InfrastructureModels.silence()

ipopt_solver = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "print_level"=>0)
ecos_solver = JuMP.optimizer_with_attributes(ECOS.Optimizer, "verbose"=>0)
juniper_solver = JuMP.optimizer_with_attributes(Juniper.Optimizer, "nl_solver"=>ipopt_solver, "log_levels"=>[])

include("common.jl")

@testset "InfrastructureModels Tests" begin

include("data.jl")

include("base.jl")

include("constraint.jl")

include("relaxation_scheme.jl")

end
