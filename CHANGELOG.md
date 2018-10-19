InfrastructureModels.jl Change Log
==================================

### Staged
- nothing

### v0.0.10
- Add support for Julia v0.7/v1.0 (thanks to @jd-lara)
- Lower replicate count bound to 1 instead of 2

### v0.0.9
- Adding conic form of the complex product relaxation

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
