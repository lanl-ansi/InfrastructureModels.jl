using InfrastructureModels
using Logging
# suppress warnings during testing
Logging.configure(level=ERROR)

@testset "InfrastructureModels Tests" begin

include("data.jl")

end