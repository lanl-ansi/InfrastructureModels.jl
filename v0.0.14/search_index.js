var documenterSearchIndex = {"docs": [

{
    "location": "index.html#",
    "page": "Home",
    "title": "Home",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#InfrastructureModels.jl-Documentation-1",
    "page": "Home",
    "title": "InfrastructureModels.jl Documentation",
    "category": "section",
    "text": "CurrentModule = InfrastructureModels"
},

{
    "location": "index.html#Overview-1",
    "page": "Home",
    "title": "Overview",
    "category": "section",
    "text": "InfrastructureModels.jl is a Julia package for shared functionality across multiple inftrastructure optimizatoin packages. It primarily provides utilities for parsing and modifying data."
},

{
    "location": "index.html#Installation-1",
    "page": "Home",
    "title": "Installation",
    "category": "section",
    "text": "Typically InfrastructureModels is not useful on its own and is included as a requirement for other package.  To test that the package work correctly run,Pkg.test(\"InfrastructureModels\")"
},

{
    "location": "library.html#",
    "page": "Library",
    "title": "Library",
    "category": "page",
    "text": ""
},

{
    "location": "library.html#InfrastructureModels.update_data!-Tuple{Dict{String,#s14} where #s14,Dict{String,#s15} where #s15}",
    "page": "Library",
    "title": "InfrastructureModels.update_data!",
    "category": "method",
    "text": "recursively applies new_data to data, overwriting information\n\n\n\n\n\n"
},

{
    "location": "library.html#InfrastructureModels._bold-Tuple{String}",
    "page": "Library",
    "title": "InfrastructureModels._bold",
    "category": "method",
    "text": "Makes a string bold in the terminal\n\n\n\n\n\n"
},

{
    "location": "library.html#InfrastructureModels._float2string-Tuple{AbstractFloat,Int64}",
    "page": "Library",
    "title": "InfrastructureModels._float2string",
    "category": "method",
    "text": "converts a float value into a string of fixed precision\n\nsprintf would do the job but this work around is needed because sprintf cannot take format strings during runtime\n\n\n\n\n\n"
},

{
    "location": "library.html#InfrastructureModels._grey-Tuple{String}",
    "page": "Library",
    "title": "InfrastructureModels._grey",
    "category": "method",
    "text": "Makes a string grey in the terminal, does not seem to work well on Windows terminals more info can be found at https://en.wikipedia.org/wiki/ANSIescapecode\n\n\n\n\n\n"
},

{
    "location": "library.html#InfrastructureModels._iscomponentdict-Tuple{Dict}",
    "page": "Library",
    "title": "InfrastructureModels._iscomponentdict",
    "category": "method",
    "text": "Attempts to determine if the given data is a component dictionary\n\n\n\n\n\n"
},

{
    "location": "library.html#InfrastructureModels._update_data!-Tuple{Dict{String,#s12} where #s12,Dict{String,#s17} where #s17}",
    "page": "Library",
    "title": "InfrastructureModels._update_data!",
    "category": "method",
    "text": "recursive call of updatedata\n\n\n\n\n\n"
},

{
    "location": "library.html#InfrastructureModels._value2string-Tuple{Any,Int64}",
    "page": "Library",
    "title": "InfrastructureModels._value2string",
    "category": "method",
    "text": "converts any value to a string, summarizes arrays and dicts\n\n\n\n\n\n"
},

{
    "location": "library.html#InfrastructureModels.add_line_delimiter-Tuple{AbstractString,Any,Any}",
    "page": "Library",
    "title": "InfrastructureModels.add_line_delimiter",
    "category": "method",
    "text": "\n\n\n\n"
},

{
    "location": "library.html#InfrastructureModels.arrays_to_dicts!-Tuple{Dict{String,#s73} where #s73}",
    "page": "Library",
    "title": "InfrastructureModels.arrays_to_dicts!",
    "category": "method",
    "text": "turns top level arrays into dicts\n\n\n\n\n\n"
},

{
    "location": "library.html#InfrastructureModels.check_type-Tuple{Any,Any}",
    "page": "Library",
    "title": "InfrastructureModels.check_type",
    "category": "method",
    "text": "Checks if the given value is of a given type, if not tries to make it that type\n\n\n\n\n\n"
},

{
    "location": "library.html#InfrastructureModels.compare_dict-Tuple{Any,Any}",
    "page": "Library",
    "title": "InfrastructureModels.compare_dict",
    "category": "method",
    "text": "tests if two dicts are equal, up to floating point precision\n\n\n\n\n\n"
},

{
    "location": "library.html#InfrastructureModels.compare_numbers-Tuple{Any,Any}",
    "page": "Library",
    "title": "InfrastructureModels.compare_numbers",
    "category": "method",
    "text": "tests if two numbers are equal, up to floating point precision\n\n\n\n\n\n"
},

{
    "location": "library.html#InfrastructureModels.component_table-Tuple{Dict{String,#s18} where #s18,String,Array{String,1}}",
    "page": "Library",
    "title": "InfrastructureModels.component_table",
    "category": "method",
    "text": "builds a table of component data\n\n\n\n\n\n"
},

{
    "location": "library.html#InfrastructureModels.extract_matlab_assignment-Tuple{AbstractString}",
    "page": "Library",
    "title": "InfrastructureModels.extract_matlab_assignment",
    "category": "method",
    "text": "breaks up matlab strings of the form \'name = value;\'\n\n\n\n\n\n"
},

{
    "location": "library.html#InfrastructureModels.ismultinetwork-Tuple{Dict{String,#s17} where #s17}",
    "page": "Library",
    "title": "InfrastructureModels.ismultinetwork",
    "category": "method",
    "text": "checks if a given network data is a multinetwork\n\n\n\n\n\n"
},

{
    "location": "library.html#InfrastructureModels.parse_matlab_cells-Tuple{Any,Any}",
    "page": "Library",
    "title": "InfrastructureModels.parse_matlab_cells",
    "category": "method",
    "text": "\n\n\n\n"
},

{
    "location": "library.html#InfrastructureModels.parse_matlab_data-NTuple{4,Any}",
    "page": "Library",
    "title": "InfrastructureModels.parse_matlab_data",
    "category": "method",
    "text": "\n\n\n\n"
},

{
    "location": "library.html#InfrastructureModels.parse_matlab_matrix-Tuple{Any,Any}",
    "page": "Library",
    "title": "InfrastructureModels.parse_matlab_matrix",
    "category": "method",
    "text": "\n\n\n\n"
},

{
    "location": "library.html#InfrastructureModels.print_summary-Tuple{Dict{String,#s17} where #s17}",
    "page": "Library",
    "title": "InfrastructureModels.print_summary",
    "category": "method",
    "text": "prints the text summary for a data dictionary to stdout\n\n\n\n\n\n"
},

{
    "location": "library.html#InfrastructureModels.relaxation_complex_product-NTuple{5,Any}",
    "page": "Library",
    "title": "InfrastructureModels.relaxation_complex_product",
    "category": "method",
    "text": "constraint: c^2 + d^2 <= a*b\n\n\n\n\n\n"
},

{
    "location": "library.html#InfrastructureModels.relaxation_complex_product_conic-NTuple{5,Any}",
    "page": "Library",
    "title": "InfrastructureModels.relaxation_complex_product_conic",
    "category": "method",
    "text": "a conic encoding of constraint: c^2 + d^2 <= a*b\n\n\n\n\n\n"
},

{
    "location": "library.html#InfrastructureModels.relaxation_complex_product_on_off-NTuple{6,Any}",
    "page": "Library",
    "title": "InfrastructureModels.relaxation_complex_product_on_off",
    "category": "method",
    "text": "c^2 + d^2 <= a*b*getupperbound(z)\nc^2 + d^2 <= getupperbound(a)*b*getupperbound(z)\nc^2 + d^2 <= a*getupperbound(b)*z\n\n\n\n\n\n"
},

{
    "location": "library.html#InfrastructureModels.relaxation_equality_on_off-NTuple{4,Any}",
    "page": "Library",
    "title": "InfrastructureModels.relaxation_equality_on_off",
    "category": "method",
    "text": "x - getupperbound(x)*(1-z) <= y <= x - getlowerbound(x)*(1-z)\n\n\n\n\n\n"
},

{
    "location": "library.html#InfrastructureModels.relaxation_product-NTuple{4,Any}",
    "page": "Library",
    "title": "InfrastructureModels.relaxation_product",
    "category": "method",
    "text": "general relaxation of binlinear term (McCormick)\n\nz >= getlowerbound(x)*y + getlowerbound(y)*x - getlowerbound(x)*getlowerbound(y)\nz >= getupperbound(x)*y + getupperbound(y)*x - getupperbound(x)*getupperbound(y)\nz <= getlowerbound(x)*y + getupperbound(y)*x - getlowerbound(x)*getupperbound(y)\nz <= getupperbound(x)*y + getlowerbound(y)*x - getupperbound(x)*getlowerbound(y)\n\n\n\n\n\n"
},

{
    "location": "library.html#InfrastructureModels.relaxation_product_on_off-NTuple{5,Any}",
    "page": "Library",
    "title": "InfrastructureModels.relaxation_product_on_off",
    "category": "method",
    "text": "On/Off variant of binlinear term (McCormick) requires that all variables (x,y,z) go to zero with ind\n\n\n\n\n\n"
},

{
    "location": "library.html#InfrastructureModels.relaxation_sqr-Tuple{Any,Any,Any}",
    "page": "Library",
    "title": "InfrastructureModels.relaxation_sqr",
    "category": "method",
    "text": "general relaxation of a square term\n\nx^2 <= y <= (getupperbound(x)+getlowerbound(x))*x - getupperbound(x)*getlowerbound(x)\n\n\n\n\n\n"
},

{
    "location": "library.html#InfrastructureModels.relaxation_trilinear-NTuple{6,Any}",
    "page": "Library",
    "title": "InfrastructureModels.relaxation_trilinear",
    "category": "method",
    "text": "convex hull relaxation of trilinear term\n\nw₁ = getlowerbound(x)*getlowerbound(y)*getlowerbound(z)\nw₂ = getlowerbound(x)*getlowerbound(y)*getupperbound(z)\nw₃ = getlowerbound(x)*getupperbound(y)*getlowerbound(z)\nw₄ = getlowerbound(x)*getupperbound(y)*getupperbound(z)\nw₅ = getupperbound(x)*getlowerbound(y)*getlowerbound(z)\nw₆ = getupperbound(x)*getlowerbound(y)*getupperbound(z)\nw₇ = getupperbound(x)*getupperbound(y)*getlowerbound(z)\nw₈ = getupperbound(x)*getupperbound(y)*getupperbound(z)\nw = λ₁*w₁ + λ₂*w₂ + λ₃*w₃ + λ₄*w₄ + λ₅*w₅ + λ₆*w₆ + λ₇*w₇ + λ₈*w₈\nx = (λ₁ + λ₂ + λ₃ + λ₄)*getlowerbound(x) + (λ₅ + λ₆ + λ₇ + λ₈)*getupperbound(x)\ny = (λ₁ + λ₂ + λ₅ + λ₆)*getlowerbound(x) + (λ₃ + λ₄ + λ₇ + λ₈)*getupperbound(x)\nz = (λ₁ + λ₃ + λ₅ + λ₇)*getlowerbound(x) + (λ₂ + λ₄ + λ₆ + λ₈)*getupperbound(x)\nλ₁ + λ₂ + λ₃ + λ₄ + λ₅ + λ₆ + λ₇ + λ₈ = 1\n\n\n\n\n\n"
},

{
    "location": "library.html#InfrastructureModels.replicate-Tuple{Dict{String,#s20} where #s20,Int64}",
    "page": "Library",
    "title": "InfrastructureModels.replicate",
    "category": "method",
    "text": "Transforms a single network into a multinetwork with several deepcopies of the original network\n\n\n\n\n\n"
},

{
    "location": "library.html#InfrastructureModels.row_to_dict-Tuple{Any,Any}",
    "page": "Library",
    "title": "InfrastructureModels.row_to_dict",
    "category": "method",
    "text": "takes a row from a matrix and assigns the values names\n\n\n\n\n\n"
},

{
    "location": "library.html#InfrastructureModels.row_to_typed_dict-Tuple{Any,Any}",
    "page": "Library",
    "title": "InfrastructureModels.row_to_typed_dict",
    "category": "method",
    "text": "takes a row from a matrix and assigns the values names and types\n\n\n\n\n\n"
},

{
    "location": "library.html#InfrastructureModels.split_line-Tuple{AbstractString}",
    "page": "Library",
    "title": "InfrastructureModels.split_line",
    "category": "method",
    "text": "\n\n\n\n"
},

{
    "location": "library.html#InfrastructureModels.summary-Tuple{IO,Dict{String,#s36} where #s36}",
    "page": "Library",
    "title": "InfrastructureModels.summary",
    "category": "method",
    "text": "prints the text summary for a data dictionary to IO\n\n\n\n\n\n"
},

{
    "location": "library.html#InfrastructureModels.type_array-Union{Tuple{Array{T,1}}, Tuple{T}} where T<:AbstractString",
    "page": "Library",
    "title": "InfrastructureModels.type_array",
    "category": "method",
    "text": "Attempts to determine the type of an array of strings extracted from a matlab file\n\n\n\n\n\n"
},

{
    "location": "library.html#InfrastructureModels.type_value-Tuple{AbstractString}",
    "page": "Library",
    "title": "InfrastructureModels.type_value",
    "category": "method",
    "text": "Attempts to determine the type of a string extracted from a matlab file\n\n\n\n\n\n"
},

{
    "location": "library.html#InfrastructureModels.jl-Library-1",
    "page": "Library",
    "title": "InfrastructureModels.jl Library",
    "category": "section",
    "text": "Modules = [InfrastructureModels]"
},

{
    "location": "developer.html#",
    "page": "Developer",
    "title": "Developer",
    "category": "page",
    "text": ""
},

{
    "location": "developer.html#Developer-Documentation-1",
    "page": "Developer",
    "title": "Developer Documentation",
    "category": "section",
    "text": ""
},

{
    "location": "developer.html#JSON-Data-Format-1",
    "page": "Developer",
    "title": "JSON Data Format",
    "category": "section",
    "text": "InfrastructureModels and dependent packages leverage an extensible JSON-based data format.  This allows arbitrary extensions by the dependent packages and their users.  This section discusses the data standards that are consistent across dependent packages and extensions."
},

{
    "location": "developer.html#Single-Network-Data-1",
    "page": "Developer",
    "title": "Single Network Data",
    "category": "section",
    "text": "All network data has one required parameter,per_unit: a boolean value indicating if component parameters are in mixed-units or per unitand three optional parameters,multinetwork: a boolean value indicating if the data represents a single network or multiple networks (assumed to be false when not present)\nname: a human readable name for the network\ndescription: a textual description of the network and any related notesThese top level parameters can be accompanied by collections of components, where the component name is the key of the collection.  A minimalist network dataset would be,{\n\"per_unit\": <boolean>,\n(\"multinetwork\": false,)\n(\"name\": <string>,)\n(\"description\": <string>,)\n\"component_1\": {...},\n\"component_2\": {...},\n...\n\"component_j\": {...}\n}Each component collection is a lookup table of the form index-to-component_data.  Each component has two required parameters,index: the component\'s unique integer value, which is also its lookup id\nstatus: an integer that takes 1 or 0 indicating if the component is active or inactive, respectivelyand three optional parameters,name: a human readable name for the component\nsource_id: a string representation of a unique id from a source dataset\ndispatchable: a boolean value indicating the component can be controlled or not.  The default value is component dependent and some component types may ignore this parameter.A typical component collection has a form along these lines,{\n\"component_1\":{\n    \"1\":{\n        \"index\": 1,\n        \"status\": <int>,\n        (\"name\": <string>,)\n        (\"source_id\": <string>,)\n        (\"dispatchable\": <boolean>,)\n        ...\n    },\n    \"2\":{\n        \"index\": 2,\n        \"status\" :<int>,\n        (\"name\": <string>,)\n        (\"source_id\": <string>,)\n        (\"dispatchable\": <boolean>,)\n        ...\n    }\n    ...\n    \"k\":{\n        \"index\": k,\n        \"status\" <int>,\n        (\"name\": <string>,)\n        (\"source_id\": <string>,)\n        (\"dispatchable\": <boolean>,)\n        ...\n    }\n},\n...\n}"
},

{
    "location": "developer.html#Multi-Network-Data-1",
    "page": "Developer",
    "title": "Multi Network Data",
    "category": "section",
    "text": "If the multinetwork parameter is true then several single network data objects are wrapped in a nw lookup table, like so,{\n\"multinetwork\": true,\n\"per_unit\": <boolean>,\n(\"name\": <string>,)\n(\"description\": <string>,)\n\"nw\":{\n    \"1\":{\n        \"index\": <int>,\n        (\"name\": <string>,)\n        (\"description\": <string>,)\n        \"component_1\": {...},\n        ...\n        \"component_j\": {...}\n    },\n    \"2\":{\n        \"index\": <int>,\n        (\"name\": <string>,)\n        (\"description\": <string>,)\n        \"component_1\": {...},\n        ...\n        \"component_j\": {...}\n    },\n    ...\n    \"i\":{\n        \"index\": <int>,\n        (\"name\": <string>,)\n        (\"description\": <string>,)\n        \"component_1\": {...},\n        ...\n        \"component_j\": {...}\n    },\n}\n}"
},

{
    "location": "developer.html#Multi-Infrastructure-Data-(proposed)-1",
    "page": "Developer",
    "title": "Multi Infrastructure Data (proposed)",
    "category": "section",
    "text": "If the data include the parameter multiinfrastructure, then network data objects are wrapped in a mi lookup table, that uses special string names for each type of infrastructure.  Each infrastructure data object can include a single network or a multi network of that infrastructure type.  Multi network lookup keys are assumed to be consistent across multiple infrastructure datasets.{\n\"multiinfrastructure\": true,\n\"mi\":{\n    \"ep\": {...},\n    \"ng\": {...},\n    \"pw\": {...},\n    ...\n}\n}"
},

{
    "location": "developer.html#Variable-Naming-Conventions-1",
    "page": "Developer",
    "title": "Variable Naming Conventions",
    "category": "section",
    "text": ""
},

{
    "location": "developer.html#Suffixes-1",
    "page": "Developer",
    "title": "Suffixes",
    "category": "section",
    "text": "_fr: from-side (\'i\'-node)\n_to: to-side (\'j\'-node)"
},

]}
