module InfrastructureModels

import JuMP
import Logging
import LoggingExtras

# Setup Logging
include("core/logging.jl")
_DEFAULT_LOGGER = Logging.current_logger()
_LOGGER = Logging.ConsoleLogger(; meta_formatter=InfrastructureModels._dispatching_metafmt)
function __init__()
    global _DEFAULT_LOGGER = Logging.current_logger()
    global _LOGGER = Logging.ConsoleLogger(; meta_formatter=InfrastructureModels._dispatching_metafmt)
    register_module!(InfrastructureModels, _im_metafmt)
    Logging.global_logger(_LOGGER)
end

"allows the user to set the logging level without the need to add Logging"
function logger_config!(level; kwargs...)
    set_logging_level!(Symbol(uppercase(level[1]) * level[2:end]))
end

const nw_id_default = 0

include("core/base.jl")
include("core/data.jl")
include("core/constraint.jl")
include("core/relaxation_scheme.jl")
include("core/ref.jl")
include("core/solution.jl")

include("io/common.jl")
include("io/matlab.jl")

include("core/export.jl")

end
