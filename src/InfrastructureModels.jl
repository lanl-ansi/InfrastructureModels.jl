module InfrastructureModels

import JuMP
import Memento

import MathOptInterface
const _MOI = MathOptInterface

# Create our module level logger (this will get precompiled)
const _LOGGER = Memento.getlogger(@__MODULE__)

# Register the module level logger at runtime so that folks can access the logger via `getlogger(InfrastructureModels)`
# NOTE: If this line is not included then the precompiled `Infrastructure.LOGGER` won't be registered at runtime.
__init__() = Memento.register(_LOGGER)

"Suppresses information and warning messages output by InfrastructureModels, for fine grained control use the Memento package"
function silence()
    Memento.info(_LOGGER, "Suppressing information and warning messages for the rest of this session.  Use the Memento package for more fine-grained control of logging.")
    Memento.setlevel!(_LOGGER, "error")
end

"alows the user to set the logging level without the need to add Memento"
function logger_config!(level; kwargs...)
    Memento.config!(_LOGGER, level, kwargs...)
end

include("core/base.jl")
include("core/data.jl")
include("core/relaxation_scheme.jl")
include("core/solution.jl")

include("io/common.jl")
include("io/matlab.jl")

include("core/export.jl")

end