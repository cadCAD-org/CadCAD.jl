function state_prey_update(state::State; timestep::Int64, substep::Int64)
    prey_change = (PreyGrowth * state.prey_population) - (PreyDeath * state.prey_population * state.predator_population)
    prey_pop_on_dt = state.prey_population + (prey_change * DT)
    updated_prey_pop = prey_pop_on_dt > 0.0 ? prey_pop_on_dt : 0.0
    State(timestep, substep, updated_prey_pop, state.predator_population)
end

function state_stochastic_prey_update(state::State; timestep::Int64, substep::Int64)
    updated_prey_pop = state.prey_population * (1 + rand() / 1000)
    State(timestep, substep, updated_prey_pop, state.predator_population)
end

function state_predator_update(state::State; timestep::Int64, substep::Int64)
    predator_change = (PredatorGrowth * state.prey_population * state.predator_population) - (PredatorDeath * state.predator_population)
    predator_pop_on_dt = state.predator_population + (predator_change * DT)
    updated_predator_pop = predator_pop_on_dt > 0.0 ? predator_pop_on_dt : 0.0
    State(timestep, substep, state.prey_population, updated_predator_pop)
end

substep_block_1 = (state_prey_update, state_predator_update)
substep_block_2 = (state_stochastic_prey_update,)

pipeline = (substep_block_1, substep_block_2)
