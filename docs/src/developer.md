# Developer Documentation

## JSON Data Format

InfrastructureModels and dependent packages leverage an extensible JSON-based data format.  This allows arbitrary extensions by the dependent packages and their users.  This section discusses the data standards that are consistent across dependent packages and extensions.

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
* `dispatchable`: a boolean value indicating the component can be controlled or not.  The default value is component dependent and some component types may ignore this parameter.

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


### Multi Network Data

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