# Developer Documentation

## Getting Started

InfrastructureModels is a lightweight package that provides a foundation of shared functionality across sector-specific extensions of InfrastructureModels (e.g., see [GasModels](https://github.com/lanl-ansi/GasModels.jl), [PowerModels](https://github.com/lanl-ansi/PowerModels.jl), [GasPowerModels](https://github.com/lanl-ansi/GasPowerModels.jl))
This foundation provide basic structure for sector-specific extensions but does not explicitly enforce some common conventions of the InfrastructureModels ecosystem, which are a best-practice to use.
This documentation provides an introduction to the process of developing new InfrastructureModels packages, however we recommend engaging with the developers of InfrastructureModels for additional support in the development process.

## New Package Development

Developing a new InfrastructureModels package begins by building a new Julia package, usually base around a new infrastructure sector.  For the sake of illustration, this new package will be named `NewSectorModels`.

### Package Organization

The Julia programming language does not require or benefit from any specific package structure.  However, as code bases grow, developing an organization of Julia code into files helps to manage the organization of the information. To help provide consistency of code organization across InfrastructureModels packages the following package `src` file structure is recommended,

* `NewSectorModels.jl` - root entry point of the package (required by Julia)
* `core` - the essential features of the package
  * `base.jl` - Definition of the most foundational functions of the package including the base type `AbstractNewSectorModel <: AbstractInfrastructureModel` and specializations of the common InfrastructureModels functions
  * `constraint_template.jl` - templates for formulation agnostic constraints that will be called from the sector-specific mathematical models
  * `constraint.jl` - formulation agnostic implementations of mathematical constraints
  * `data.jl` - tools for working with sector-specific data dictionaries
  * `export.jl` - an internal tool for only exporting functions that do not begin with `_`
  * `objective.jl` - formulation agnostic implementations of objective functions
  * `ref.jl` - tools for working with sector-specific reference dictionaries
  * `solution.jl` - tools for working with sector-specific solution dictionaries
  * `types.jl` - all of the sub-types of `AbstractNewSectorModel` that will be used in this package
  * `variable.jl` - formulation agnostic implementations of variable definitions
* `form` - overloads of `core` functions that are specialized to specific model formulations (via sub-types of `AbstractNewSectorModel`)
* `io` - tools for reading and writing sector-specific data files
* `prob` - formulation agnostic sector-specific mathematical models (i.e., problems)


### Foundation Specialization

To leverage the foundational capabilities of InfrastructureModels the `NewSectorModels` package needs to define some key parameters and specialize a number of the generic functions provided in InfrastructureModels.

This specialization begins by selecting a unique short-name for the package, the convention is to use the capital letters in the package name.  For example, a package called `NewSectorModels` it would have a short name of `nsm`.
The convention is that the package will document its short name with the following constants in `NewSectorModels.jl`,
```
const nsm_it_name = "nsm"
const nsm_it_sym = Symbol(nsm_it_name)
const _nsm_global_keys = Set(["time_series", "per_unit"])
```
These constants are then used to specialize foundational InfrastructureModels functions in this sector-specific package.

!!! warning
    The package short-name must be unique across the InfrastructureModels ecosystem.
    This is how each package is able to maintain a namespace that does interfere with another one.

The specialization continues by overloading InfrastructureModels functions and providing `nsm_it_sym` and `_nsm_global_keys` as default arguments to these more generic methods. Overloading these functions is optional but recommended as a convenience to the users of the `NewSectorModels`, who often will not encounter any other package in the InfrastructureModels ecosystem.  The following InfrastructureModels functions are recommended for overloading,
```
instantiate_model, build_ref, nw_ids, nws, ids, ref, var, con, sol,
ismultinetwork, ismultiinfrastructure, make_multinetwork, replicate,
sol_component_fixed, sol_component_value, sol_component_value_edge,
apply!, summary
```


## Data Format

InfrastructureModels and dependent packages leverage an extensible JSON-based data format. 
This allows arbitrary extensions by the dependent packages and their users. 
This section discusses the data standards that are consistent across dependent packages and extensions.

### Single Network Data

All network data has one required parameter,
* `per_unit`: a boolean value indicating if component parameters are in mixed-units or per unit
and three optional parameters,
* `multinetwork`: a boolean value indicating if the data represents a single network or multiple networks (assumed to be `false` when not present)
* `name`: a human readable name for the network
* `description`: a textual description of the network and any related notes

These top level parameters can be accompanied by collections of components, where the component name is the key of the collection.  A minimalist network dataset would be,

```json
{
"per_unit": <boolean>,
("multinetwork": false,)
("name": <string>,)
("description": <string>,)
"component_1": {...},
"component_2": {...},
...
"component_j": {...}
}
```


Each component collection is a lookup table of the form `index`-to-`component_data`.  Each component has two required parameters,
* `index`: the component's unique integer value, which is also its lookup id
* `status`: an integer that takes 1 or 0 indicating if the component is active or inactive, respectively
and three optional parameters,
* `name`: a human readable name for the component
* `source_id`: a string representation of a unique id from a source dataset

A typical component collection has a form along these lines,

```json
{
"component_1":{
    "1":{
        "index": 1,
        "status": <int>,
        ("name": <string>,)
        ("source_id": <string>,)
        ("dispatchable": <boolean>,)
        ...
    },
    "2":{
        "index": 2,
        "status" :<int>,
        ("name": <string>,)
        ("source_id": <string>,)
        ("dispatchable": <boolean>,)
        ...
    }
    ...
    "k":{
        "index": k,
        "status" <int>,
        ("name": <string>,)
        ("source_id": <string>,)
        ("dispatchable": <boolean>,)
        ...
    }
},
...
}
```


### Multi-network Data

If the `multinetwork` parameter is `true` then several single network data objects are wrapped in a `nw` lookup table, like so,

```json
{
"multinetwork": true,
"per_unit": <boolean>,
("name": <string>,)
("description": <string>,)
"nw":{
    "1":{
        "index": <int>,
        ("name": <string>,)
        ("description": <string>,)
        "component_1": {...},
        ...
        "component_j": {...}
    },
    "2":{
        "index": <int>,
        ("name": <string>,)
        ("description": <string>,)
        "component_1": {...},
        ...
        "component_j": {...}
    },
    ...
    "i":{
        "index": <int>,
        ("name": <string>,)
        ("description": <string>,)
        "component_1": {...},
        ...
        "component_j": {...}
    },
}
}
```

### Multi-infrastructure Data
Network data objects are wrapped in an infrastructure type (`it`) lookup table that uses special names for each type of infrastructure.
Each infrastructure data object can include a single network or a multinetwork of that infrastructure type.
Data that describe the linkages between interdependent infrastructures are defined in the `dep` block.

```json
{
"it": {
    "dep": {...},
    "pm": {...},
    "gm": {...},
    "wm": {...},
    ...
},
...
}
```

Some InfrastructureModels short names include,
```
Interdependencies - dep
Power Transmission - pm
Power Distribution - pmd
Natural Gas Transmission - gm
Water Distribution - wm
```

## Variable Naming Conventions

### Suffixes

- `_fr`: from-side ('i'-node)
- `_to`: to-side ('j'-node)
