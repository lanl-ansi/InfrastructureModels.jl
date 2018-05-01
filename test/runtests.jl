using InfrastructureModels
using Memento
using JSON

# Suppress warnings during testing.
setlevel!(getlogger(InfrastructureModels), "error")

using Base.Test

include("common.jl")

@testset "InfrastructureModels Tests" begin

include("data.jl")

include("relaxation_scheme.jl")

end