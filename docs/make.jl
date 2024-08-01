using cadCAD
using Documenter

DocMeta.setdocmeta!(cadCAD, :DocTestSetup, :(using cadCAD); recursive = true)

makedocs(;
    modules = [cadCAD],
    authors = "Emanuel Lima <emanuel-lima@outlook.com>",
    repo = "https://github.com/cadCAD-org/cadCAD.jl/blob/{commit}{path}#{line}",
    sitename = "cadCAD.jl",
    format = Documenter.HTML(;
        prettyurls = get(ENV, "CI", "false") == "true",
        canonical = "https://cadCAD-org.github.io/cadCAD.jl",
        edit_link = "main",
        assets = String[]
    ),
    pages = [
        "Home" => "index.md"
    ]
)

deploydocs(;
    repo = "github.com/cadCAD-org/cadCAD.jl",
    devbranch = "main"
)
