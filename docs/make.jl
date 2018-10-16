using Documenter, InfrastructureModels

makedocs(
    modules = [InfrastructureModels],
    format = :html,
    sitename = "InfrastructureModels",
    authors = "Carleton Coffrin, Russell Bent, and contributors",
    #analytics = "UA-367975-10",
    pages = [
        "Home" => "index.md",
        "Library" => "library.md",
        "Developer" => "developer.md"
    ]
)

deploydocs(
    deps = nothing,
    make = nothing,
    target = "build",
    repo = "github.com/lanl-ansi/InfrastructureModels.jl.git",
    julia = "1.0"
)
