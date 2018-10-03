using InfrastructureModels
using Memento
using JSON

if VERSION > v"0.7.0-"
    using Tests
end

# Suppress warnings during testing.
setlevel!(getlogger(InfrastructureModels), "error")

include("common.jl")

@testset "InfrastructureModels Tests" begin

include("data.jl")

include("relaxation_scheme.jl")

end