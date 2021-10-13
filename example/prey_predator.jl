using Distributions, cadCAD

# Configuring the simulations
# Invariant: ALL states will have: timestep::Int64 and substep::Int64
# Invariant: ALL initial conditions must have the same type signature
initial_conditions_alpha = (prey_population = [100.0, 5.0], 
                            predator_population = 15.0)

initial_conditions_beta = (prey_population = 150.0, 
                           predator_population = 10.0)

state_signature = generate_state_signature(initial_conditions_alpha)
@state_factory "prey_population::Float64 predator_population::Float64"
#= dump(State) =#

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
function prey_policy(state::State; params::NamedTuple)
    updated_prey_pop = state.prey_population * rand(Uniform(0.9, 1.1))
    return (signal_prey = updated_prey_pop)
end

function predator_policy(state::State; params::NamedTuple)
    updated_predator_pop = state.predator_population * rand(Uniform(0.9, 1.1))
    return (signal_predator = updated_predator_pop)
end

# State Update Functions
function state_prey_update(state::State; timestep::Int64, substep::Int64, params::NamedTuple, signal::Union{NamedTuple,State})
    prey_change = (params["prey_birth_rate"] * state.prey_population) - (params["prey_death_rate"] * state.prey_population * state.predator_population)
    prey_pop_on_dt = state.prey_population + (prey_change * params["dt"])
    updated_prey_pop = prey_pop_on_dt > 0.0 ? prey_pop_on_dt : 0.0
    return State(timestep, substep, updated_prey_pop, state.predator_population)
end

function state_predator_update(state::State; timestep::Int64, substep::Int64, params::NamedTuple, signal::Union{NamedTuple,State})
    predator_change = (params["predator_birth_rate"] * state.prey_population * state.predator_population) - (params["predator_death_rate"] * state.predator_population)
    predator_pop_on_dt = state.predator_population + (predator_change * params["dt"])
    updated_predator_pop = predator_pop_on_dt > 0.0 ? predator_pop_on_dt : 0.0
    return State(timestep, substep, state.prey_population, updated_predator_pop)
end

run_experiment("experiment.toml")
