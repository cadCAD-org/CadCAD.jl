module Simulation

# Configure
import Configure

function run_experiment()
    Configure.config_state()

    for simulation_name in keys(Configure.exp_config["simulations"])
        simulation_run(simulation_name)
    end
end

function simulation_run(simulation_name::String)
    trajectory = Vector{State}(nothing, Configure.exp_config["simulations"][simulation_name]["timesteps"])

    # Function to initialize from the initial conditions dict?
    initial_state = State(?)

    push!(trajectory, initial_state)

    for _ = 1:Configure.exp_config["simulations"][simulation_name]["n_runs"]
        for timestep = 1:Configure.exp_config["simulations"][simulation_name]["timesteps"]
            for (substep, substep_block) in enumerate(Configure.exp_config["simulations"][simulation_name]["pipeline"])
                for func in substep_block
                    push!(trajectory, func(history[end], timestep=timestep, substep=substep))
                end
            end
        end
    end

    # Save the trajectory

end
