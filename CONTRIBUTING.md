# Contributing to CadCAD.jl

[![Aqua Static Badge](https://img.shields.io/badge/tested_with-aqua.jl-00FFFF?style=for-the-badge&logo=julia&logoColor=white)](https://github.com/JuliaTesting/Aqua.jl)
[![Jet Static Badge](https://img.shields.io/badge/tested_with-jet.jl-000080?style=for-the-badge&logo=julia&logoColor=white)](https://github.com/aviatesk/JET.jl)

Thanks for taking the time to contribute. We appreciate it very much!

Any contribution to CadCAD.jl is welcome in the following ways:

- Modifying the code or documentation with a [pull request](https://github.com/cadCAD-org/CadCAD.jl/pulls).
- Reporting bugs and feature requests in the [issues section](https://github.com/cadCAD-org/CadCAD.jl/issues) of the project's Github.
- Opening or engaging in [discussions](https://github.com/cadCAD-org/CadCAD.jl/discussions)

Remeber that all new code must be accompanied by unit tests.

## Previewing Documentation Edits

Modifications to the documentation can be previewed by building the documentation locally, which is made possible by a script located in docs/make.jl. The Documenter package is required and can be installed by running `import Pkg; Pkg.add("Documenter")` in a REPL session. Then the documentation can be built and previewed in build/ first by running `julia docs/make.jl` from a terminal.
