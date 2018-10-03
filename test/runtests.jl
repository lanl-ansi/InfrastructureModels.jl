using InfrastructureModels
using Memento
using JSON
using Test

# Suppress warnings during testing.
setlevel!(getlogger(InfrastructureModels), "error")

include("common.jl")

@testset "InfrastructureModels Tests" begin

include("data.jl")

include("relaxation_scheme.jl")

end