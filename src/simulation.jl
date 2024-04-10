module Simulation

export run_simulation

include("spaces.jl")

import Base.Iterators
using CSV, DataFrames, StructArrays, PrettyTables, JSONTables
using Base.Threads, Logging, Comonicon, ProgressLogging
using .Spaces, cadCAD

function run_simulation(exp_config::Dict, simulation_name::String)
    # create the configurations from system model
    # sets of configurations
    params = eval(Symbol(exp_config["simulations"][simulation_name]["params"]))
    init_conditions = eval(Symbol(exp_config["simulations"][simulation_name]["initial_conditions"]))
    sweep_strategy = exp_config["simulations"][simulation_name]["sweep"]

    if max_param_length(params) > 1 && sweep_strategy == "cartesian"
        @info "Using a cartesian sweep of the parameters..."
        params_set = Iterators.product(params...)
    elseif max_param_length(params) > 1
        @info "Using a simple sweep of the parameters..."
        params_set = generate_job(exp_matrix(params))
    else
        @info "No sweep of the parameters..."
        params_set = (params,)
    end

    if max_param_length(init_conditions) > 1 && sweep_strategy == "cartesian"
        @info "Using a cartesian sweep of the state..."
        state_set = Iterators.product(init_conditions...)
    elseif max_param_length(init_conditions) > 1
        @info "Using a simple sweep of the state..."
        state_set = generate_job(exp_matrix(init_conditions))
    else
        @info "No sweep of the state..."
        state_set = (init_conditions,)
    end

    for (s_order, state) in enumerate(state_set)
        # Send @info with markdown
        init_state = State(; state...)
        for (p_order, params) in enumerate(params_set)
            final_data = Vector{DataFrame}(undef, exp_config["simulations"][simulation_name]["n_runs"])
            for n_run = 1:exp_config["simulations"][simulation_name]["n_runs"]
                trajectory = StructArray{State}(undef, 1)
                trajectory[1] = init_state
                @progress "Run $n_run:" for timestep = 1:exp_config["simulations"][simulation_name]["timesteps"]
                    signal_vec = Vector{NamedTuple}(undef, 0)
                    # Policies application
                    # Lock the signal_vec?
                    # Use @spawn?
                    if nthreads() > 1
                        @threads for func in exp_config["simulations"][simulation_name]["pipeline"]["policies"]
                            policy = eval(Symbol(func))
                            push!(signal_vec, policy(; state = trajectory[end], params = params))
                        end
                    else
                        for func in exp_config["simulations"][simulation_name]["pipeline"]["policies"]
                            policy = eval(Symbol(func))
                            dump(policy)
                            push!(signal_vec, policy(; state = trajectory[end], params = params))
                        end
                    end

                    # Signal production (aggregation)
                    final_signal = aggregate_signal(exp_config["simulations"][simulation_name]["aggregation"], signal_vec)

                    # SUFs application
                    # Lock the trajectory?
                    # Use @spawn?
                    if nthreads() > 1
                        @threads for (substep, func) in enumerate(exp_config["simulations"][simulation_name]["pipeline"]["sufs"])
                            suf = eval(Symbol(func))
                            new_state = suf(; state = trajectory[end], timestep = timestep, substep = substep, params = params, signal = final_signal)
                            push!(trajectory, new_state)
                        end
                    else
                        for (substep, func) in enumerate(exp_config["simulations"][simulation_name]["pipeline"]["sufs"])
                            suf = eval(Symbol(func))
                            new_state = suf(; state = trajectory[end], timestep = timestep, substep = substep, params = params, signal = final_signal)
                            push!(trajectory, new_state)
                        end
                    end
                end
                final_data[n_run] = DataFrame(StructArrays.components(trajectory), copycols = false)
            end
            if "table" in exp_config["simulations"][simulation_name]["output"]
                foreach(trajectory_df -> pretty_table(trajectory_df), final_data)
            end
            if "csv" in exp_config["simulations"][simulation_name]["output"]
                foreach(trajectory_df -> CSV.write("results_$(simulation_name)_run$(n_run)_paramsweep$(p_order)_statesweep$(s_order).csv",
                        trajectory_df), final_data)
            end
            if "json" in exp_config["simulations"][simulation_name]["output"]
                foreach(trajectory_df -> open("results_$(simulation_name)_run$(n_run)_paramsweep$(p_order)_statesweep$(s_order).json", "w") do io
                        write(io, objecttable(trajectory_df))
                    end, final_data)
            end
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
    return (view(experiment_matrix, :, i) for i = 1:size(experiment_matrix, 2))
end

end
