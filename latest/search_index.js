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
    "location": "library.html#InfrastructureModels.update_data!-Tuple{Dict{String,Any},Dict{String,Any}}",
    "page": "Library",
    "title": "InfrastructureModels.update_data!",
    "category": "method",
    "text": "recursively applies new_data to data, overwriting information\n\n\n\n"
},

{
    "location": "library.html#InfrastructureModels._bold-Tuple{String}",
    "page": "Library",
    "title": "InfrastructureModels._bold",
    "category": "method",
    "text": "Makes a string bold in the terminal\n\n\n\n"
},

{
    "location": "library.html#InfrastructureModels._float2string-Tuple{AbstractFloat,Int64}",
    "page": "Library",
    "title": "InfrastructureModels._float2string",
    "category": "method",
    "text": "converts a float value into a string of fixed precision\n\nsprintf would do the job but this work around is needed because sprintf cannot take format strings during runtime\n\n\n\n"
},

{
    "location": "library.html#InfrastructureModels._grey-Tuple{String}",
    "page": "Library",
    "title": "InfrastructureModels._grey",
    "category": "method",
    "text": "Makes a string grey in the terminal, does not seem to work well on Windows terminals more info can be found at https://en.wikipedia.org/wiki/ANSI_escape_code\n\n\n\n"
},

{
    "location": "library.html#InfrastructureModels._update_data!-Tuple{Dict{String,Any},Dict{String,Any}}",
    "page": "Library",
    "title": "InfrastructureModels._update_data!",
    "category": "method",
    "text": "recursive call of _update_data\n\n\n\n"
},

{
    "location": "library.html#InfrastructureModels._value2string-Tuple{Any,Int64}",
    "page": "Library",
    "title": "InfrastructureModels._value2string",
    "category": "method",
    "text": "converts any value to a string, summarizes arrays and dicts\n\n\n\n"
},

{
    "location": "library.html#InfrastructureModels.add_line_delimiter-Tuple{AbstractString,Any,Any}",
    "page": "Library",
    "title": "InfrastructureModels.add_line_delimiter",
    "category": "method",
    "text": "\n\n"
},

{
    "location": "library.html#InfrastructureModels.arrays_to_dicts!-Tuple{Dict{String,Any}}",
    "page": "Library",
    "title": "InfrastructureModels.arrays_to_dicts!",
    "category": "method",
    "text": "turns top level arrays into dicts\n\n\n\n"
},

{
    "location": "library.html#InfrastructureModels.check_type-Tuple{Any,Any}",
    "page": "Library",
    "title": "InfrastructureModels.check_type",
    "category": "method",
    "text": "Checks if the given value is of a given type, if not tries to make it that type\n\n\n\n"
},

{
    "location": "library.html#InfrastructureModels.extract_matlab_assignment-Tuple{AbstractString}",
    "page": "Library",
    "title": "InfrastructureModels.extract_matlab_assignment",
    "category": "method",
    "text": "breaks up matlab strings of the form \'name = value;\'\n\n\n\n"
},

{
    "location": "library.html#InfrastructureModels.parse_matlab_cells-Tuple{Any,Any}",
    "page": "Library",
    "title": "InfrastructureModels.parse_matlab_cells",
    "category": "method",
    "text": "\n\n"
},

{
    "location": "library.html#InfrastructureModels.parse_matlab_data-NTuple{4,Any}",
    "page": "Library",
    "title": "InfrastructureModels.parse_matlab_data",
    "category": "method",
    "text": "\n\n"
},

{
    "location": "library.html#InfrastructureModels.parse_matlab_matrix-Tuple{Any,Any}",
    "page": "Library",
    "title": "InfrastructureModels.parse_matlab_matrix",
    "category": "method",
    "text": "\n\n"
},

{
    "location": "library.html#InfrastructureModels.print_summary-Tuple{Dict{String,Any}}",
    "page": "Library",
    "title": "InfrastructureModels.print_summary",
    "category": "method",
    "text": "prints the text summary for a data dictionary to STDOUT\n\n\n\n"
},

{
    "location": "library.html#InfrastructureModels.replicate-Tuple{Dict{String,Any},Int64}",
    "page": "Library",
    "title": "InfrastructureModels.replicate",
    "category": "method",
    "text": "Transforms a single network into a multinetwork with several deepcopies of the original network\n\n\n\n"
},

{
    "location": "library.html#InfrastructureModels.split_line-Tuple{AbstractString}",
    "page": "Library",
    "title": "InfrastructureModels.split_line",
    "category": "method",
    "text": "\n\n"
},

{
    "location": "library.html#InfrastructureModels.summary-Tuple{IO,Dict{String,Any}}",
    "page": "Library",
    "title": "InfrastructureModels.summary",
    "category": "method",
    "text": "prints the text summary for a data dictionary to IO\n\n\n\n"
},

{
    "location": "library.html#InfrastructureModels.type_array-Union{Tuple{Array{T,1}}, Tuple{T}} where T<:AbstractString",
    "page": "Library",
    "title": "InfrastructureModels.type_array",
    "category": "method",
    "text": "Attempts to determine the type of an array of strings extracted from a matlab file\n\n\n\n"
},

{
    "location": "library.html#InfrastructureModels.type_value-Tuple{AbstractString}",
    "page": "Library",
    "title": "InfrastructureModels.type_value",
    "category": "method",
    "text": "Attempts to determine the type of a string extracted from a matlab file\n\n\n\n"
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
    "text": "All network data has two required parameters,multinetwork: a boolean value indicating if the data represents a single network or multiple networks\nper_unit: a boolean value indicating if the parameter units are in mixed-units or per unitcomponent lists These two parameters can be accompanied by collections of components, where the component name is the key of the collection.  The name parameter is optional and can be used to give a human readable name for the network data.  A minimalist network dataset would be,{\n\"multinetwork\": false,\n\"per_unit\": <boolean>,\n\"name\": <string>,\n\"component_1\": {...},\n\"component_2\": {...},\n...\n\"component_j\": {...}\n}Each component collection is a lookup table of the form index to component_data, for convenience each component includes its index value as an internal parameter.  Each component additionally has a required value called status which takes 1 or 0 indicating if the component is active or inactive, respectively, and on optional parameter called name, which is a human readable name for the component.  A typical component collection as a form along these lines,{\n\"component_1\":{\n    \"1\":{\n        \"index\": <int>,\n        \"status\": <int>,\n        \"name\": <string>,\n        ...\n    },\n    \"2\":{\n        \"index\": <int>,\n        \"status\" :<int>,\n        \"name\": <string>,\n        ...\n    }\n    ...\n    \"k\":{\n        \"index\": <int>,\n        \"status\" <int>,\n        \"name\": <string>,\n        ...\n    }\n},\n...\n}"
},

{
    "location": "developer.html#Multi-Network-Data-1",
    "page": "Developer",
    "title": "Multi Network Data",
    "category": "section",
    "text": "If the multinetwork parameter is true then several single network data objects are wrapped in a nw lookup table, like so,{\n\"multinetwork\": true,\n\"per_unit\": <boolean>,\n\"name\": <string>,\n\"nw\":{\n    \"1\":{\n        \"index\": <int>,\n        \"name\": <string>,\n        \"component_1\": {...},\n        ...\n        \"component_j\": {...}\n    },\n    \"2\":{\n        \"index\": <int>,\n        \"name\": <string>,\n        \"component_1\": {...},\n        ...\n        \"component_j\": {...}\n    },\n    ...\n    \"i\":{\n        \"index\": <int>,\n        \"name\": <string>,\n        \"component_1\": {...},\n        ...\n        \"component_j\": {...}\n    },\n}\n}"
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
