""
function build_result(aim::AbstractInfrastructureModel, solve_time; solution_processors=[])
    # try-catch is needed until solvers reliably support ResultCount()
    result_count = 1
    try
        result_count = JuMP.result_count(aim.model)
    catch
        Memento.warn(_LOGGER, "the given optimizer does not provide the ResultCount() attribute, assuming the solver returned a solution which may be incorrect.");
    end

    solution = Dict{String,Any}()

    if result_count > 0
        solution = build_solution(aim, post_processors=solution_processors)
    else
        Memento.warn(_LOGGER, "model has no results, solution cannot be built")
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
    sol = Dict{String, Any}("it" => Dict{String, Any}())
    sol["multiinfrastructure"] = true

    for it in it_ids(aim)
        sol["it"][string(it)] = build_solution_values(aim.sol[:it][it])
        sol["it"][string(it)]["multinetwork"] = true
    end

    solution_preprocessor(aim, sol)

    for post_processor in post_processors
        post_processor(aim, sol)
    end

    for it in it_ids(aim)
        it_str = string(it)
        data_it = ismultiinfrastructure(aim) ? aim.data["it"][it_str] : aim.data

        if ismultinetwork(data_it)
            sol["it"][it_str]["multinetwork"] = true
        else
            for (k, v) in sol["it"][it_str]["nw"]["$(nw_id_default)"]
                sol["it"][it_str][k] = v
            end

            sol["it"][it_str]["multinetwork"] = false
            delete!(sol["it"][it_str], "nw")
        end

        if !ismultiinfrastructure(aim)
            for (k, v) in sol["it"][it_str]
                sol[k] = v
            end

            delete!(sol["it"], it_str)
        end
    end

    if !ismultiinfrastructure(aim)
        sol["multiinfrastructure"] = false
        delete!(sol, "it")
    end

    return sol
end


""
function build_solution_values(var::Dict)
    sol = Dict{String, Any}()

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
    return [build_solution_values(var[i, j]) for i in 1:size(var, 1), j in 1:size(var, 2)]
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
function sol_component_fixed(aim::AbstractInfrastructureModel, it::Symbol, n::Int, comp_name::Symbol, field_name::Symbol, comp_ids, constant)
    for i in comp_ids
        @assert !haskey(sol(aim, it, n, comp_name, i), field_name)
        sol(aim, it, n, comp_name, i)[field_name] = constant
    end
end

"given a variable that is indexed by component ids, builds the standard solution structure"
function sol_component_value(aim::AbstractInfrastructureModel, it::Symbol, n::Int, comp_name::Symbol, field_name::Symbol, comp_ids, variables)
    for i in comp_ids
        @assert !haskey(sol(aim, it, n, comp_name, i), field_name)
        sol(aim, it, n, comp_name, i)[field_name] = variables[i]
    end
end

"maps asymmetric edge variables into components"
function sol_component_value_edge(aim::AbstractInfrastructureModel, it::Symbol, n::Int, comp_name::Symbol, field_name_fr::Symbol, field_name_to::Symbol, comp_ids_fr, comp_ids_to, variables)
    for (l, i, j) in comp_ids_fr
        @assert !haskey(sol(aim, it, n, comp_name, l), field_name_fr)
        sol(aim, it, n, comp_name, l)[field_name_fr] = variables[(l, i, j)]
    end

    for (l, i, j) in comp_ids_to
        @assert !haskey(sol(aim, it, n, comp_name, l), field_name_to)
        sol(aim, it, n, comp_name, l)[field_name_to] = variables[(l, i, j)]
    end
end
