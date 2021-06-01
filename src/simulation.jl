module Simulation

import MetaEngine, TOML
using CSV, DataFrames, StructArrays

function run_experiment(config_path::String)
    const exp_config = TOML.tryparsefile(config_path)

    # I need any simulation_name
    # To get any initial_conditions dict in order to config_state()
    sim_name = collect(keys(exp_config["simulations"]))[1]
    init_state = eval(Symbol(exp_config["simulations"][sim_name]["initial_conditions"]))

    MetaEngine.config_state(init_state)

    for simulation_name in keys(exp_config["simulations"])
        if exp_config["simulations"][simulation_name]["enabled"]
            run_simulation(simulation_name)
        else
            println("Skipping $simulation_name because it was disabled...")
        end
    end
end

function run_simulation(simulation_name::String)
    trajectory = StructArray{State}(undef, 0)

    initial_state = make_initial_state(simulation_name)

    push!(trajectory, initial_state)

    for n_run = 1:exp_config["simulations"][simulation_name]["n_runs"]
        for timestep = 1:exp_config["simulations"][simulation_name]["timesteps"]
            for (substep, substep_block) in enumerate(exp_config["simulations"][simulation_name]["pipeline"])
                for func_str in substep_block
                    func = Symbol(func_str)
                    
                end
                push!(trajectory, func(trajectory[end], timestep=timestep, substep=substep))
            end
        end

        data = DataFrame(StructArrays.components(trajectory), copycols=false)
        CSV.write("results_$(simulation_name)_run$(n_run).csv", data)
    end
end

function make_initial_state(simulation_name::String)
    init_state = eval(Symbol(exp_config["simulations"][simulation_name]["initial_conditions"]))
    state_tuple = (;(Symbol(variable) => value for (variable, value) in init_state)...)

    return State(; state_tuple...)
end

end
