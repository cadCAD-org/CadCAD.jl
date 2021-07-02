using Documenter
using cadCAD

makedocs(
    sitename = "cadCAD",
    format = Documenter.HTML(),
    modules = [cadCAD]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
#=deploydocs(
    repo = "<repository url>"
)=#
