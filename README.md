# InfrastructureModels

<img src="https://lanl-ansi.github.io/InfrastructureModels.jl/dev/assets/logo.svg" align="left" width="200" alt="InfrastructureModels logo">

Status:
[![CI](https://github.com/lanl-ansi/InfrastructureModels.jl/workflows/CI/badge.svg)](https://github.com/lanl-ansi/InfrastructureModels.jl/actions?query=workflow%3ACI)
[![codecov](https://codecov.io/gh/lanl-ansi/InfrastructureModels.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/lanl-ansi/InfrastructureModels.jl)
[![Documentation](https://github.com/lanl-ansi/InfrastructureModels.jl/workflows/Documentation/badge.svg)](https://lanl-ansi.github.io/InfrastructureModels.jl/stable/)
</p>

InfrastructureModels encompasses shared functionalities, best practices, and style guides for a multi-infrastructure modeling and optimization ecosystem in Julia. The core packages in the InfrastructureModels ecosystem are,

* [GasModels](https://github.com/lanl-ansi/GasModels.jl) - Natural gas transmission systems
* [PetroleumModels](https://github.com/lanl-ansi/PetroleumModels.jl) - Petroleum product transmission systems
* [PowerModels](https://github.com/lanl-ansi/PowerModels.jl) - Electrical power transmission systems
* [PowerModelsDistribution](https://github.com/lanl-ansi/PowerModelsDistribution.jl) - Electrical power distribution systems
* [WaterModels](https://github.com/lanl-ansi/WaterModels.jl) - Potable water distribution systems

Additionally, the following multi-infrastructure modeling packages have been developed,

* [GasPowerModels](https://github.com/lanl-ansi/GasPowerModels.jl) - Natural gas and electrical power transmission systems
* [PowerWaterModels](https://github.com/lanl-ansi/PowerWaterModels.jl) - Electrical power and potable water distribution systems
* [PowerModelsITD](https://github.com/lanl-ansi/PowerModelsITD.jl) - Electrical power transmission and distribution

For information about developing infrastructure modeling packages for new infrastructure types or new combinations of existing infrastructure types, please see the [developer section](https://lanl-ansi.github.io/InfrastructureModels.jl/stable/developer/) of the package documentation.


## License
This code is provided under a [modified BSD license](https://github.com/lanl-ansi/InfrastructureModels.jl/blob/master/LICENSE.md) as part of the Multi-Infrastructure Control and Optimization Toolkit (MICOT), LA-CC-13-108.
