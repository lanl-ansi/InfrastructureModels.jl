using InfrastructureModels
using JSON
using Compat

if VERSION > v"0.7.0-"
    using Test
    using Logging
    Logging.disable_logging(Logging.Warn)
end

if VERSION < v"0.7.0-"
    using Memento
    using Base.Test
    setlevel!(getlogger(InfrastructureModels), "error")
end


include("common.jl")

@testset "InfrastructureModels Tests" begin

include("data.jl")

include("relaxation_scheme.jl")

end