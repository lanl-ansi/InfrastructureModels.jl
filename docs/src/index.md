# InfrastructureModels Documentation

```@meta
CurrentModule = InfrastructureModels
```

## Overview

InfrastructureModels is a Julia package for shared functionality across multiple infrastructure optimization packages. It provides standardized utilities for,
* processing dictionary-based infrastructure data
* building `InfrastructureModels` data-structures
* instantiating infrastructure mathematical models
* shared mathematical formulations that arise across infrastructure models
* optimizing the mathematical models
* building optimization result data-structures

Developers interested in adding a package to the InfrastructureModels ecosystem should review the [InfrastructureModels Library](@ref) and [Developer Documentation](@ref) documentation to develop an initial understanding and get started. Additional questions can be directed to the active developers of InfrastructureModels.

## Installation

Typically InfrastructureModels is not useful on its own and is included as a requirement for other package.  To test that the package is working correctly run,

```julia
] test InfrastructureModels
```
