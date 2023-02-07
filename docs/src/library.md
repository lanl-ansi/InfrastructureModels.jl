# InfrastructureModels Library

## Overview

The core functionalities provided by InfrastructureModels are organized into the following files in the `src` directory,

* `core/base.jl` - tools for building, accessing and optimizing InfrastructureModels mathematical models 
* `core/constraint.jl` - abstract mathematical constraints that occur across many types of InfrastructureModels
* `core/data.jl` - tools for working with data dictionaries that conform to the InfrastructureModels data standards
* `core/export.jl` - an internal tool for only exporting functions that do not begin with `_`
* `core/ref.jl` - tools for working with reference dictionaries (`ref`) that conform to the InfrastructureModels standards
* `core/relaxation_scheme.jl` - abstract mathematical constraints implementing convex relaxations of functions that occur across many types of InfrastructureModels
* `core/solution.jl` - tools for building optimization result dictionaries in the InfrastructureModels standard format
* `io/matlab.jl` - basic tools for parsing matlab files for reading standard infrastructure data formats, such as the [Matpower](https://matpower.org/) data format

## API Reference

Below is a complete list of all components of InfrastructureModels with documentation strings when available. Following the [JuMP developer style guide](https://jump.dev/JuMP.jl/stable/developers/style/), items beginning with `_` are for InfrastructureModels internal use only, while other elements are exported for use and extension by other packages.

```@autodocs
Modules = [InfrastructureModels]
```