module InfrastructureModels

import JuMP
import Logging

function __init__()
    logger_config!("info")
    return
end

const nw_id_default = 0

include("core/logging.jl")
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
