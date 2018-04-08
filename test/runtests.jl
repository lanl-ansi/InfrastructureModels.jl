using InfrastructureModels
using Memento
using JSON

# Suppress warnings during testing.
setlevel!(getlogger(InfrastructureModels), "error")

using Base.Test

@testset "InfrastructureModels Tests" begin

include("data.jl")

end