using Distributions
using cadCAD

#= 
Configuring the simulations.
Invariant: ALL states will have: timestep::Int64 and substep::Int64.
Invariant: ALL initial conditions must have the same type signature. =#
initial_conditions_alpha = (prey_population = 100.0, 
                            predator_population = 15.0)

initial_conditions_beta = (prey_population = 150.0, 
                           predator_population = 10.0)

#= 
The engine will generate a type State based on the NamedTuple
declared as initial_conditions on the TOML.
The type State will never change for the duration of the simulation.
So if a different State, with different type signatures is necessary,
the user has to create another system model. =#
generate_state_type(initial_conditions_alpha)

# Definition of parameters
parameters_alpha = (prey_birth_rate = 1.0, 
                    predator_birth_rate = 0.01, 
                    predator_death_rate = 1.0, 
                    prey_death_rate = 0.03, 
                    dt = 0.1)

parameters_beta = (prey_birth_rate = 0.9, 
                   predator_birth_rate = 0.05, 
                   predator_death_rate = 1.1, 
                   prey_death_rate = 0.07, 
                   dt = 0.2)

# Policies
function prey_policy(; state::State, params::NamedTuple)
    updated_prey_pop = state.prey_population * rand(Uniform(0.9, 1.1))
    return (signal_prey = updated_prey_pop,)
end

function predator_policy(; state::State, params::NamedTuple)
    updated_predator_pop = state.predator_population * rand(Uniform(0.9, 1.1))
    return (signal_predator = updated_predator_pop,)
end

# State Update Functions
function state_prey_update(; state::State, timestep::Int64, substep::Int64, params::NamedTuple, signal::Union{NamedTuple,State})
    prey_change = (params["prey_birth_rate"] * state.prey_population) - (params["prey_death_rate"] * state.prey_population * state.predator_population)
    prey_pop_on_dt = state.prey_population + (prey_change * params["dt"]) + signal.signal_prey
    updated_prey_pop = prey_pop_on_dt > 0.0 ? prey_pop_on_dt : 0.0
    return State(; prey_population=updated_prey_pop, predator_population=state.predator_population, timestep=timestep, substep=substep)
end

function state_predator_update(; state::State, timestep::Int64, substep::Int64, params::NamedTuple, signal::Union{NamedTuple,State})
    predator_change = (params["predator_birth_rate"] * state.prey_population * state.predator_population) - (params["predator_death_rate"] * state.predator_population)
    predator_pop_on_dt = state.predator_population + (predator_change * params["dt"]) + signal.signal_predator
    updated_predator_pop = predator_pop_on_dt > 0.0 ? predator_pop_on_dt : 0.0
    return State(; prey_population=state.prey_population, predator_population=updated_predator_pop, timestep=timestep, substep=substep)
end

#= 
This is the second necessary step.
Start cadCAD.jl based on TOML configuration.
The @__FILE__ argument is just a necessary boilerplate. =#
run_experiment("experiment.toml", @__FILE__)
