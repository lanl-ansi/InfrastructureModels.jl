using InfrastructureModels
using Memento
using JSON
using Compat

if VERSION > v"0.7.0-"
    using Test
end

if VERSION < v"0.7.0-"
    using Base.Test
end

# Suppress warnings during testing.
setlevel!(getlogger(InfrastructureModels), "error")

include("common.jl")

@testset "InfrastructureModels Tests" begin

include("data.jl")

include("relaxation_scheme.jl")

end