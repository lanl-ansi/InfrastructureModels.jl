# Developer Documentation

## JSON Data Format

InfrastructureModels and dependent packages leverage an extensible JSON-based data format.  This allows arbitrary extensions by the dependent packages and their users.  This section discusses the data standards that are consistent across dependent packages and extensions.

### Single Network Data

All network data has two parameters,
* `multinetwork`: a boolean value indicating if the data represents a single network or multiple networks
* `per_unit`: a boolean value indicating if the parameter units are in mixed-units or per unit
component lists
These two parameters can be accompanied by collections of components, where the component name is the key of the collection.  A minimalist network dataset would be,

```json
{
"multinetwork": false,
"per_unit": <boolean>,
"component_1": {...},
"component_2": {...},
...
"component_j": {...}
}
```


Each component collection is a lookup table of the form `index` to `component_data`, for convenience each component includes its `index` value as an internal parameter.  Each component additionally has a required value called `status` which takes 1 or 0 indicating if the component is active or inactive, respectively, and on optional parameter called `name`, which is a human readable name for the component.  A typical component collection as a form along these lines,

```json
{
"component_1":{
    "1":{
        "index": <int>,
        "status": <int>,
        "name": <string>,
        ...
    },
    "2":{
        "index": <int>,
        "status" :<int>,
        "name": <string>,
        ...
    }
    ...
    "k":{
        "index": <int>,
        "status" <int>,
        "name": <string>,
        ...
    }
},
...
}
```


### Multi Network Data

If the `multinetwork` parameter is `true` then several single network data objects are wrapped in a `nw` lookup table, like so,

```json
{
"multinetwork": true,
"per_unit": <boolean>,
"nw":{
    "1":{
        "index": <int>,
        "component_1": {...},
        ...
        "component_j": {...}
    },
    "2":{
        "index": <int>,
        "component_1": {...},
        ...
        "component_j": {...}
    },
    ...
    "i":{
        "index": <int>,
        "component_1": {...},
        ...
        "component_j": {...}
    },
}
}
```


### Multi Infrastructure Data (proposed)

If the data include the parameter `multiinfrastructure`, then network data objects are wrapped in a `mi` lookup table, that uses special string names for each type of infrastructure.  Each infrastructure data object can include a single network or a multi network of that infrastructure type.  Multi network lookup keys are assumed to be consistent across multiple infrastructure datasets.

```json
{
"multiinfrastructure": true,
"mi":{
    "ep": {...},
    "ng": {...},
    "pw": {...},
    ...
}
}
```


## Variable Naming Conventions

### Suffixes

- `_fr`: from-side ('i'-node)
- `_to`: to-side ('j'-node)