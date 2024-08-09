using CadCAD
using Documenter

DocMeta.setdocmeta!(CadCAD, :DocTestSetup, :(using CadCAD); recursive = true)

makedocs(;
    modules = [CadCAD],
    authors = "Emanuel Lima <emanuel-lima@outlook.com>",
    repo = "https://github.com/cadCAD-org/CadCAD.jl/blob/{commit}{path}#{line}",
    sitename = "CadCAD.jl",
    format = Documenter.HTML(;
        prettyurls = get(ENV, "CI", "false") == "true",
        canonical = "https://cadCAD-org.github.io/CadCAD.jl",
        edit_link = "main",
        assets = String[]
    ),
    pages = [
        "Home" => "index.md"
    ]
)

deploydocs(;
    repo = "github.com/cadCAD-org/CadCAD.jl",
    devbranch = "main"
)
