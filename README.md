# cadCAD.jl

This Work in Progress cadCAD implementation in Julia uses a Meta Engine approach. This represents a development initiative for a high performance engine for experienced modelers to run large experiments.

## Building

cadCAD.jl is a standallone CLI app, so it needs to be compiled to be used. To do so:

1. Install the latest stable release of [Julia](https://julialang.org/downloads/);
2. Clone this repository;
3. Do, from the root of the repository: `julia --project deps/build.jl app`

This will create a `build` folder that contains a `cadCAD` folder that is the compiled app. You can `tar` the folder to distriute the app or just relocate it anywhere on your system. The `cadCAD` executable is in the `build/cadCAD/bin` folder.
