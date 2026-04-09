"""
Shared logging infrastructure for InfrastructureModels and downstream packages.

Design: A single EarlyFilteredLogger is the global logger. It wraps a ConsoleLogger
with a dispatching meta_formatter. Packages register their module and formatter via
`register_module!`. Per-module log levels are stored in `_MODULE_LOG_LEVELS` — a Dict
that the filter function checks. `silence!()` / `set_logging_level!()` just update
this Dict and rebuild the global logger.
"""

# --- Shared state ---

"Per-module log level overrides. Modules not in this dict use the default (pass all)."
const _MODULE_LOG_LEVELS = Dict{Module, Logging.LogLevel}()

"Per-module meta formatters. Registered via register_module!."
const _MODULE_FORMATTERS = Dict{Module, Function}()


# --- Meta formatter ---

"""
    _im_metafmt(level::Logging.LogLevel, _module, group, id, file, line)

Default MetaFormatter for the shared ConsoleLogger.
"""
function _im_metafmt(level::Logging.LogLevel, _module, group, id, file, line)
    @nospecialize
    color = Logging.default_logcolor(level)
    prefix = "$(_module) | " * (level == Logging.Warn ? "Warning" : string(level)) * " ] :"
    suffix = ""
    Logging.Info <= level < Logging.Warn && return color, prefix, suffix
    _module !== nothing && (suffix *= "$(_module)")
    if file !== nothing
        _module !== nothing && (suffix *= " ")
        suffix *= Base.contractuser(file)
        if line !== nothing
            suffix *= ":$(isa(line, UnitRange) ? "$(first(line))-$(last(line))" : line)"
        end
    end
    !isempty(suffix) && (suffix = "@ " * suffix)

    return color, prefix, suffix
end

"""
    _dispatching_metafmt(level, _module, group, id, file, line)

Routes to the registered formatter for `_module`, or falls back to `_im_metafmt`.
"""
function _dispatching_metafmt(level::Logging.LogLevel, _module, group, id, file, line)
    fmt = get(_MODULE_FORMATTERS, _module, _im_metafmt)
    return fmt(level, _module, group, id, file, line)
end


# --- Filter & logger construction ---

"""
    _should_log(log)

EarlyFilteredLogger filter function. Checks `_MODULE_LOG_LEVELS` dict.
If the log's module has a level override and the message is below it, suppress.
"""
function _should_log(log)
    min_level = get(_MODULE_LOG_LEVELS, log._module, Logging.BelowMinLevel)
    return log.level >= min_level
end

"""
    _rebuild_global_logger!()

Rebuilds the global logger from current state. Called after any change to
`_MODULE_LOG_LEVELS`. If no modules have level overrides, sets bare ConsoleLogger.
"""
function _rebuild_global_logger!()
    if isempty(_MODULE_LOG_LEVELS)
        Logging.global_logger(_LOGGER)
    else
        Logging.global_logger(LoggingExtras.EarlyFilteredLogger(_should_log, _LOGGER))
    end
    return
end


# --- Public API: registration (for downstream packages) ---

"""
    register_module!(mod::Module, metafmt::Function)

Register a downstream package's module and its meta formatter.
Called in the downstream package's `__init__()`.
"""
function register_module!(mod::Module, metafmt::Function)
    _MODULE_FORMATTERS[mod] = metafmt
    return
end


# --- Public API: level control (InfrastructureModels-specific) ---

"""
    silence!()

Sets loglevel for InfrastructureModels to `:Error`, silencing Info and Warn.
"""
function silence!()
    set_logging_level!(:Error)
end

"""
    set_logging_level!(level::Symbol)

Sets the logging level for InfrastructureModels: `:Info`, `:Warn`, `:Error`.
"""
function set_logging_level!(level::Symbol)
    _MODULE_LOG_LEVELS[InfrastructureModels] = getfield(Logging, level)
    _rebuild_global_logger!()
    return
end

"""
    reset_logging_level!()

Removes InfrastructureModels' log level override, restoring default behavior.
"""
function reset_logging_level!()
    delete!(_MODULE_LOG_LEVELS, InfrastructureModels)
    _rebuild_global_logger!()
    return
end

"""
    restore_global_logger!()

Restores the global logger to its default state (before InfrastructureModels was loaded).
"""
function restore_global_logger!()
    Logging.global_logger(_DEFAULT_LOGGER)
    return
end


# --- Public API: generic per-module control (for downstream packages) ---

"""
    set_module_log_level!(mod::Module, level::Logging.LogLevel)

Set a log level filter for a specific module. Messages from `mod` below `level`
are suppressed. Other modules are unaffected.
"""
function set_module_log_level!(mod::Module, level::Logging.LogLevel)
    _MODULE_LOG_LEVELS[mod] = level
    _rebuild_global_logger!()
    return
end

"""
    reset_module_log_level!(mod::Module)

Remove the log level filter for a specific module, restoring its default behavior.
"""
function reset_module_log_level!(mod::Module)
    delete!(_MODULE_LOG_LEVELS, mod)
    _rebuild_global_logger!()
    return
end


# --- Public API: logging + throw (replaces Memento.error behavior) ---

"""
    @log_error(msg)

Logs `msg` at error level via `@error`, then throws an `ErrorException`.
This replicates the behavior of `Memento.error(logger, msg)`, which both logged
a grepable error record and threw.
"""
macro log_error(msg)
    file = string(__source__.file)
    line = __source__.line
    return quote
        Base.@logmsg Logging.Error $(esc(msg)) _file=$(file) _line=$(line)
        error($(esc(msg)))
    end
end
