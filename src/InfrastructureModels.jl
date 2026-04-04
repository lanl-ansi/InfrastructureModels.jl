module InfrastructureModels

import JuMP
import Logging

"Suppresses information and warning messages output by InfrastructureModels, for fine grained control use the Logging package"
function silence()
    @info "Suppressing information and warning messages for the rest of this session.  Use the Logging package for more fine-grained control of logging."
    Logging.disable_logging(Logging.Warn)
end

"allows the user to set the logging level without the need to add Logging"
function logger_config!(level; kwargs...)
    Logging.disable_logging(_im_parse_log_level(level))
end

"Maps a minimum-visible level string to the highest level that should be disabled.
`disable_logging(level)` disables all messages at `level` and below."
function _im_parse_log_level(level::AbstractString)
    if level == "debug"
        return Logging.LogLevel(Logging.Debug - 1)  # disable nothing
    elseif level == "info"
        return Logging.Debug                         # disable Debug only
    elseif level == "warn"
        return Logging.Info                          # disable Debug, Info
    elseif level == "error"
        return Logging.Warn                          # disable Debug, Info, Warn
    else
        return Logging.LogLevel(Logging.Debug - 1)   # default: disable nothing
    end
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
