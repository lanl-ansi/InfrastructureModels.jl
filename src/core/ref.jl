function ref_add_function!(ref_function::Function, it::Symbol, ref::Dict{Symbol, <:Any}, data::Dict{String, <:Any})
    # Get the portion of the data dictionary that corresponds to the specific infrastructure.
    data_it = ismultiinfrastructure(data) ? data["it"][string(it)] : data

    # Ensure the data dictionary used for processing looks like a multinetwork.
    nws_data = ismultinetwork(data_it) ? data_it["nw"] : Dict("0" => data_it)

    for (n, nw_data) in nws_data
        # For each subnetwork, apply ref_function.
        nw_ref = ref[:it][it][:nw][parse(Int, n)]
        ref_function(nw_ref, nw_data)
    end
end
