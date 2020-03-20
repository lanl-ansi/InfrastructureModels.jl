""
function build_result(aim::AbstractInfrastructureModel, solve_time; solution_processors=[])
    # TODO replace with JuMP.result_count(aim.model) after version v0.21
    # try-catch is needed until solvers reliably support ResultCount()
    result_count = 1
    try
        result_count = _MOI.get(aim.model, _MOI.ResultCount())
    catch
        Memento.warn(_LOGGER, "the given optimizer does not provide the ResultCount() attribute, assuming the solver returned a solution which may be incorrect.");
    end

    solution = Dict{String,Any}()
    if result_count > 0
        solution = build_solution(aim, post_processors=solution_processors)
    else
        Memento.warn(_LOGGER, "model has no results, solution cannot be built")
    end

    data = Dict{String,Any}("name" => aim.data["name"])
    if InfrastructureModels.ismultinetwork(aim.data)
        data_nws = data["nw"] = Dict{String,Any}()

        for (n,nw_data) in aim.data["nw"]
            data_nws[n] = Dict(
                "name" => get(nw_data, "name", "anonymous"),
            )
        end
    end

    result = Dict{String,Any}(
        "optimizer" => JuMP.solver_name(aim.model),
        "termination_status" => JuMP.termination_status(aim.model),
        "primal_status" => JuMP.primal_status(aim.model),
        "dual_status" => JuMP.dual_status(aim.model),
        "objective" => _guard_objective_value(aim.model),
        "objective_lb" => _guard_objective_bound(aim.model),
        "solve_time" => solve_time,
        "solution" => solution,
        "data" => data,
        "machine" => Dict(
            "cpu" => Sys.cpu_info()[1].model,
            "memory" => string(Sys.total_memory()/2^30, " Gb")
        )
    )

    return result
end


""
function _guard_objective_value(model)
    obj_val = NaN

    try
        obj_val = JuMP.objective_value(model)
    catch
    end

    return obj_val
end


""
function _guard_objective_bound(model)
    obj_lb = -Inf

    try
        obj_lb = JuMP.objective_bound(model)
    catch
    end

    return obj_lb
end


""
function solution_preprocessor(aim::AbstractInfrastructureModel, solution::Dict)
    # default implementation, do nothing
    # to be extended by subtypes of AbstractInfrastructureModel
end


""
function build_solution(aim::AbstractInfrastructureModel; post_processors=[])
    sol = build_solution_values(aim.sol)

    solution_preprocessor(aim, sol)

    if ismultinetwork(aim)
        sol["multinetwork"] = true
    else
        for (k,v) in sol["nw"]["$(aim.cnw)"]
            sol[k] = v
        end
        delete!(sol, "nw")
    end

    for post_processor in post_processors
        post_processor(aim, sol)
    end

    return sol
end


""
function build_solution_values(var::Dict)
    sol = Dict{String,Any}()
    for (key, val) in var
        sol[string(key)] = build_solution_values(val)
    end
    return sol
end

""
function build_solution_values(var::Array{<:Any,1})
    return [build_solution_values(val) for val in var]
end

""
function build_solution_values(var::Array{<:Any,2})
    return [build_solution_values(var[i,j]) for i in 1:size(var,1), j in 1:size(var,2)]
end

""
function build_solution_values(var::Number)
    return var
end

""
function build_solution_values(var::JuMP.VariableRef)
    return JuMP.value(var)
end

""
function build_solution_values(var::JuMP.GenericAffExpr)
    return JuMP.value(var)
end

""
function build_solution_values(var::JuMP.GenericQuadExpr)
    return JuMP.value(var)
end

""
function build_solution_values(var::JuMP.NonlinearExpression)
    return JuMP.value(var)
end

""
function build_solution_values(var::JuMP.ConstraintRef)
    return JuMP.dual(var)
end

""
function build_solution_values(var::Any)
    Memento.warn(_LOGGER, "build_solution_values found unknown type $(typeof(var))")
    return var
end


#### Helpers for populating the solution dict

"given a constant value, builds the standard component-wise solution structure"
function sol_component_fixed(aim::AbstractInfrastructureModel, n::Int, comp_name::Symbol, field_name::Symbol, comp_ids, constant)
    for i in comp_ids
        @assert !haskey(sol(aim, n, comp_name, i), field_name)
        sol(aim, n, comp_name, i)[field_name] = constant
    end
end

"given a variable that is indexed by component ids, builds the standard solution structure"
function sol_component_value(aim::AbstractInfrastructureModel, n::Int, comp_name::Symbol, field_name::Symbol, comp_ids, variables)
    for i in comp_ids
        @assert !haskey(sol(aim, n, comp_name, i), field_name)
        sol(aim, n, comp_name, i)[field_name] = variables[i]
    end
end

"maps asymmetric edge variables into components"
function sol_component_value_edge(aim::AbstractInfrastructureModel, n::Int, comp_name::Symbol, field_name_fr::Symbol, field_name_to::Symbol, comp_ids_fr, comp_ids_to, variables)
    for (l,i,j) in comp_ids_fr
        @assert !haskey(sol(aim, n, comp_name, l), field_name_fr)
        sol(aim, n, comp_name, l)[field_name_fr] = variables[(l,i,j)]
    end
    for (l,i,j) in comp_ids_to
        @assert !haskey(sol(aim, n, comp_name, l), field_name_to)
        sol(aim, n, comp_name, l)[field_name_to] = variables[(l,i,j)]
    end
end
