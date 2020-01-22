using Documenter, InfrastructureModels

makedocs(
    modules = [InfrastructureModels],
    format = Documenter.HTML(),
    sitename = "InfrastructureModels",
    authors = "Carleton Coffrin, Russell Bent, and contributors",
    pages = [
        "Home" => "index.md",
        "Library" => "library.md",
        "Developer" => "developer.md"
    ]
)

deploydocs(
    repo = "github.com/lanl-ansi/InfrastructureModels.jl.git",
)
