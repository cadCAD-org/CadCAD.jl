# WiP

module Example

using CadCAD.Spaces

# Create the spaces as kwdef structs (for now)

@kwdef struct Population <: Point
    prey_population::UInt
    predator_population::UInt
end

@kwdef struct DeltaPopulation <: Point
    delta_pop::Int
end

@kwdef struct JoinedDelta <: Point
    prey_b_delta::DeltaPopulation
    predator_b_delta::DeltaPopulation
    prey_d_delta::DeltaPopulation
    predator_d_delta::DeltaPopulation
end

# Set the parameters

params = (
    prey_birth_rate = 1.0,
    predator_birth_rate = 0.01,
    predator_death_rate = 1.0,
    prey_death_rate = 0.03,
    c_prey = 0.1,
    c_predator = 0.01
)

sim_params = (
    n_steps = 1000,
    params = params,
    n_runs = 1
)

# Define the dynamics of the simulation

function predator_births(domain::EmptySpace, codomain::DeltaPopulation, params::NamedTuple)
    delta = params.predator_birth_rate * rand(Float64) * params.c_predator
    codomain.delta_pop = floor(delta)
end

function prey_births(domain::EmptySpace, codomain::DeltaPopulation, params::NamedTuple)
    delta = params.predator_birth_rate * rand(Float64) * params.c_prey
    codomain.delta_pop = floor(delta)
end

function predator_deaths(domain::EmptySpace, codomain::DeltaPopulation, params::NamedTuple)
    delta = params.predator_death_rate * rand(Float64) * params.c_predator
    codomain.delta_pop = floor(delta)
end

function prey_deaths(domain::EmptySpace, codomain::DeltaPopulation, params::NamedTuple)
    delta = params.prey_death_rate * rand(Float64) * params.c_prey
    codomain.delta_pop = floor(delta)
end

function join_naturals(prey_b::DeltaPopulation, predator_b::DeltaPopulation,
        prey_d::DeltaPopulation, predator_d::DeltaPopulation, codomain::JoinedDelta)
    codomain.prey_b_delta = prey_b
    codomain.predator_b_delta = predator_b
    codomain.prey_d_delta = prey_d
    codomain.predator_d_delta = predator_d
end

function natural_causes(initial_pop::Population, delta::JoinedDelta, codomain::Population)
    codomain.predator_population = initial_pop.predator_population +
                                   delta.predator_b_delta.delta_pop -
                                   delta.predator_d_delta.delta_pop
    codomain.prey_population = initial_pop.prey_population + delta.prey_b_delta.delta_pop -
                               delta.prey_d_delta.delta_pop
end

function hunt(initial_pop::Population, codomain::Population)
    codomain.predator_population = initial_pop.predator_population
    codomain.prey_population = floor(initial_pop.predator_population * 0.95)
end

# Set the initial state

initial_conditions = Population(;
    prey_population = 100,
    predator_population = 15
)

# Set the pipeline

#pipeline = "((predator_births | prey_births | predator_deaths | prey_deaths) > join_naturals) > natural_causes > hunt"

# Run the simulation

#trajectory = run(initial_conditions, sim_params, pipeline)

end
