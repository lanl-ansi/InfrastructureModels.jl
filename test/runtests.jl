using InfrastructureModels
import Memento
import JSON

using Test

# Suppress warnings during testing.
Memento.setlevel!(Memento.getlogger(InfrastructureModels), "error")

include("common.jl")

@testset "InfrastructureModels Tests" begin

include("data.jl")

include("relaxation_scheme.jl")

end