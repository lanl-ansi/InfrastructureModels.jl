isdefined(Base, :__precompile__) && __precompile__()

module InfrastructureModels

import JuMP
import Memento

# Create our module level logger (this will get precompiled)
const LOGGER = Memento.getlogger(@__MODULE__)

# Register the module level logger at runtime so that folks can access the logger via `getlogger(InfrastructureModels)`
# NOTE: If this line is not included then the precompiled `Infrastructure.LOGGER` won't be registered at runtime.
__init__() = Memento.register(LOGGER)

include("core/data.jl")
include("core/relaxation_scheme.jl")

include("io/common.jl")
include("io/matlab.jl")

end