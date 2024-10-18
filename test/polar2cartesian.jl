# WiP

module Polar2Cartesian

using CadCAD: Point, run_exp

# Create the spaces as kwdef structs (for now)

@kwdef struct Cartesian <: Point
    x::Float64
    y::Float64
end

@kwdef struct Polar <: Point
    r::Float64
    phi::Float64
end

# Set the parameters

sim_params = (
    n_steps = 5,
    n_runs = 1
)

# Define the dynamics of the simulation

function cartesian2polar(cart::Cartesian)::Polar
    return Polar(
        r = sqrt(cart.x^2 + cart.y^2),
        phi = atan(cart.y, cart.x)
    )
end

function polar2cartesian(pol::Polar)::Cartesian
    return Cartesian(
        x = pol.r * cos(pol.phi),
        y = pol.r * sin(pol.phi)
    )
end

# Set the initial state

initial_conditions = Cartesian(;
    x = 1.5,
    y = 3.7
)

# Set the pipeline

pipeline = "cartesian2polar > polar2cartesian"

# Run the simulation

trajectory = run_exp(initial_conditions, sim_params, pipeline)

println(trajectory)

end
