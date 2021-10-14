module cadCAD

export run_experiment

include("meta_engine.jl")

import TOML, Base.Iterators
using CSV, DataFrames, StructArrays, Base.Threads

# Point of entry
function run_experiment(config_path::String, sys_model_path::String)
    println(raw"""
                          _  ____    _    ____    _ _ 
             ___ __ _  __| |/ ___|  / \  |  _ \  (_) |
            / __/ _` |/ _` | |     / _ \ | | | | | | |
           | (_| (_| | (_| | |___ / ___ \| |_| | | | |
            \___\__,_|\__,_|\____/_/   \_\____(_)/ |_|
                                               |__/   
          """)

    global exp_config = TOML.tryparsefile(config_path)

    println("Starting experiment ", exp_config["title"])

    println("Using $sys_model_path as system model.")
    include(filter_expr, sys_model_path)

    println("Configuring experiment based on $config_path.")

    n_threads = nthreads()
    println("Running cadCAD.jl with $n_threads thread(s).")

    for simulation_name in keys(exp_config["simulations"])
        if exp_config["simulations"][simulation_name]["enabled"]
            println("Running $simulation_name...")
            run_simulation(simulation_name)
        else
            println("Skipping $simulation_name because it was disabled...")
        end
    end
end

function run_simulation(simulation_name::String)
    # create the configurations from system model
    # sets of configurations
    params = eval(Symbol(exp_config["simulations"][simulation_name]["params"]))
    init_conditions = eval(Symbol(exp_config["simulations"][simulation_name]["initial_conditions"]))
    sweep_strategy = exp_config["simulations"][simulation_name]["sweep"]

    if max_param_length(params) > 1 && sweep_strategy == "cartesian"
        params_set = Iterators.product(params...)
    elseif max_param_length(params) > 1
        params_set = generate_job(exp_matrix(params))
    else
        params_set = (params)
    end

    println("The parameter set used is:\n $params_set")

    if max_param_length(init_conditions) > 1 && sweep_strategy == "cartesian"
        state_set = Iterators.product(init_conditions...)
    elseif max_param_length(init_conditions) > 1
        state_set = generate_job(exp_matrix(init_conditions))
    else
        state_set = (init_conditions)
    end

    println("The state set used is:\n $state_set")

    for state in state_set
        init_state = State(; state...)

        for params in params_set
            final_data = Vector{DataFrame}(undef, exp_config["simulations"][simulation_name]["n_runs"])
            for n_run = 1:exp_config["simulations"][simulation_name]["n_runs"]
                trajectory = StructArray{State}(undef, 1)
                trajectory[1] = init_state
                for timestep in trajectory
                    for subpipeline in exp_config["simulations"][simulation_name]["pipeline"]
                        for (substep, substep_block) in enumerate(subpipeline)
                            # Policies application
                            # Lock the signal_vec?
                            # Use @spawn?
                            signal_vec = Vector{NamedTuple}(undef, 0)

                            if nthreads() > 1
                                @threads for policy_str in substep_block[1]
                                    policy = Symbol(policy_str)
                                    push!(signal_vec, policy(trajectory[end], params))
                                end
                            else
                                for policy_str in substep_block[1]
                                    policy = Symbol(policy_str)
                                    push!(signal_vec, policy(trajectory[end], params))
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
                                    new_state = suf(trajectory[end], timestep, substep, params, final_signal)
                                    push!(trajectory, new_state)
                                end
                            else
                                for suf_str in substep_block[2]
                                    suf = Symbol(suf_str)
                                    new_state = suf(trajectory[end], timestep, substep, params, final_signal)
                                    push!(trajectory, new_state)
                                end
                            end
                        end
                    end
                end
                final_data[n_run] = DataFrame(StructArrays.components(trajectory), copycols=false)
                # CSV.write("results_$(simulation_name)_run$(n_run).csv", data)
            end
            println(final_data)
        end
    end
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

function exp_matrix(params::NamedTuple)
    len = max_param_length(params::NamedTuple)
    matrix = Matrix{Any}(undef, length(params), len)
    for (index, param) in enumerate(params)
        if length(param) < len
            tmp_array = fill(last(param), len - length(param))
            final_array = vcat(param, tmp_array)
            matrix[index, :] = final_array
        else
            matrix[index, :] = collect(param)
        end
    end
    return matrix
end

function max_param_length(params::NamedTuple)
    len = 0
    for param in params
        if length(param) > len
            len = length(param)
        end
    end
    return len
end

function generate_job(experiment_matrix::Matrix)
    return (view(experiment_matrix, :, i) for i in 1:size(experiment_matrix, 2))
end

function filter_expr(expr::Expr)
    if expr.head != :call
        return expr
    end
end

end
