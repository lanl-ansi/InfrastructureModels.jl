"Apply the function `func!`, which modifies `ref` using `data` for a specific
infrastructure, `it`. Here, `apply_to_subnetworks` specifies whether or
not `func!` should be applied to all subnetworks in a multinetwork dataset."
function apply!(func!::Function, ref::Dict{Symbol, <:Any}, data::Dict{String, <:Any}, it::Symbol; apply_to_subnetworks::Bool = true)
    # Get the portion of the data dictionary that corresponds to the specific infrastructure.
    data_it = ismultiinfrastructure(data) ? data["it"][string(it)] : data

    if ismultinetwork(data_it) && apply_to_subnetworks
        for (nw, nw_data) in data_it["nw"]
            nw_ref = ref[:it][it][:nw][parse(Int, nw)]
            func!(nw_ref, nw_data)
        end
    else
        func!(ref[:it][it][:nw][nw_id_default], data_it)
    end
end


"Apply the function `func!`, which modifies `ref` for a specific
infrastructure, `it`. Here, `apply_to_subnetworks` specifies whether or
not `func!` should be applied to all subnetworks in a multinetwork dataset."
function apply!(func!::Function, ref::Dict{Symbol, <:Any}, it::Symbol; apply_to_subnetworks::Bool = true)
    for (nw, nw_ref) in ref[:it][it][:nw]
        func!(nw_ref)
    end
end