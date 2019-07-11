InfrastructureModels.jl Change Log
==================================

### Staged
- nothing

### v0.2.2
- Fixed bug by adding Memento. quantifier to all logging statements

### v0.2.1
- Added variable_domain function
- Added types to relaxation schemes

### v0.2.0
- Updated to JuMP v0.19 / MathOptInterface

### v0.0.16
- Increase Memento version bounds

### v0.0.15
- Remove support for Julia v0.6/v0.7
- Fixed support for Dict{String,<:Any} types in summary function

### v0.0.14
- Update dict types to Dict{String,<:Any}

### v0.0.13
- Added arguments to the summary function for presentation order configuration, #29
- Added row_to_typed_dict and row_to_dict helper functions, #28
- Improved data standard documentation, #23, #24

### v0.0.12
- Added JuMP version upper bound
- Fixed print_summary in Julia v1.0

### v0.0.11
- Added explicit global keys argument to replicate

### v0.0.10
- Added support for Julia v0.7/v1.0 (thanks to @jd-lara)
- Lower replicate count bound to 1 instead of 2

### v0.0.9
- Added conic form of the complex product relaxation

### v0.0.8
- Update to Memento v0.8 and simplified logging config

### v0.0.7
- Removed Memento depreciation warnings

### v0.0.6
- Added ismultinetwork for checking if network data is a multinetwork

### v0.0.5
- Added component_table for building matrices from component dictionaries

### v0.0.4
- Added relaxation schemes for some typical non-convex constraints
- Made compare_dict extensible via isapprox function

### v0.0.3
- Added compare_dict function
- Added arrays_to_dicts! function
- Fixed bug when a matlab function returns a value that is not called "mpc"

### v0.0.2
- Added dict summary function
- Added update_data! function
- Added replicate function
- Added basic documentation

### v0.0.1
- Initial implementation (matlab data parsing)

