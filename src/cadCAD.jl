module cadCAD

export run_experiment, config_experiment

include("meta_engine.jl")

import TOML
using CSV, DataFrames, StructArrays, Base.Threads

# cadCAD.jl starts here
function config_experiment(config_path::String)
    println("Configuring experiment based on TOML file...")
    global exp_config = TOML.tryparsefile(config_path)

    # I need any simulation_name
    # To get any initial_conditions dict in order to config_state()
    sim_name = collect(keys(exp_config["simulations"]))[1]
    init_state = eval(Symbol(exp_config["simulations"][sim_name]["initial_conditions"]))

    config_state(init_state)

    println("Created state:")
    dump(State)
end

# Simulation starts here
function run_experiment()
    n_threads = nthreads()
    println("Running cadCAD.jl with $n_threads thread(s).")

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
    final_data = Vector{DataFrame}(undef, exp_config["simulations"][simulation_name]["n_runs"])

    initial_state = make_initial_state(simulation_name)

    push!(trajectory, initial_state)

    for n_run = 1:exp_config["simulations"][simulation_name]["n_runs"]
        for timestep = 1:exp_config["simulations"][simulation_name]["timesteps"]
            for subpipeline in exp_config["simulations"][simulation_name]["pipeline"]
                for (substep, substep_block) in enumerate(subpipeline)

                    # Policies application
                    # Lock the signal_vec?
                    # Use @spawn?
                    signal_vec = Vector{NamedTuple}(undef, 0)

                    if nthreads() > 1
                        @threads for policy_str in substep_block[1]
                            policy = Symbol(policy_str)
                            push!(signal_vec, policy(trajectory[end]))
                        end
                    else
                        for policy_str in substep_block[1]
                            policy = Symbol(policy_str)
                            push!(signal_vec, policy(trajectory[end]))
                        end
                    end

                    # Signal production (aggregation)
                    final_signal = aggregate_signal(exp_config["simulations"][simulation_name]["aggregation"], signal_vec)

                    # SUFs application
                    # Lock the trajectory?
                    # Use @spawn?
                    if nthreads() > 1
                        @threads for suf_str in substep_block[2]
                            suf = Symbol(suf_str)
                            new_state = suf(trajectory[end], timestep, substep, final_signal)
                            push!(trajectory, new_state)
                        end
                    else
                        for suf_str in substep_block[2]
                            suf = Symbol(suf_str)
                            new_state = suf(trajectory[end], timestep, substep, final_signal)
                            push!(trajectory, new_state)
                        end
                    end
                end
            end
        end

        final_data[n_run] = DataFrame(StructArrays.components(trajectory), copycols=false)
        CSV.write("results_$(simulation_name)_run$(n_run).csv", data)
    end
end

function make_initial_state(simulation_name::String)
    init_state = eval(Symbol(exp_config["simulations"][simulation_name]["initial_conditions"]))
    state_tuple = (;(Symbol(variable) => value for (variable, value) in init_state)...)

    return State(; state_tuple...)
end

function aggregate_signal(agg_func_str::String, signal_vec::Vector{NamedTuple})
    signal_dict = Dict()
    
    if isempty(agg_func_str)
        agg_func = :+
    else
        agg_func = Symbol(agg_func_str)
    end

    for signal in signal_vec
        mergewith!(agg_func, signal_dict, Dict(pairs(signal)))
    end

    return (; zip(keys(signal_dict), values(signal_dict))...)
end

end
