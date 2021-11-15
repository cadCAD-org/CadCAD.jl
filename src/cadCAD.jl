module cadCAD

include("meta_engine.jl")
include("simulation.jl")

import TOML
using Base.Threads, Base.Libc, Logging, Comonicon, TerminalLoggers
using .Simulation, .MetaEngine

const old_logger = global_logger(TerminalLogger(right_justify=120))

"""
cadCAD CLI v0.1.0

# Arguments

- `toml_path`: path to the experiment TOML
"""
@main function main(toml_path)
    println(raw"""
                          _  ____    _    ____    _ _
             ___ __ _  __| |/ ___|  / \  |  _ \  (_) |
            / __/ _` |/ _` | |     / _ \ | | | | | | |
           | (_| (_| | (_| | |___ / ___ \| |_| | | | |
            \___\__,_|\__,_|\____/_/   \_\____(_)/ |_|
                                               |__/
          """)

    exit_on_escalation()

    if !@isdefined toml_path
        @error "A TOML path was not given."
        exit(1)
    end

    exp_config = TOML.tryparsefile(toml_path)

    @info """
    \nStarting experiment $(exp_config["title"]) based on $toml_path
    With system model composed of:
    $(exp_config["simulations"]["data_structures"]) as the data structures
    and
    $(exp_config["simulations"]["functions"]) as the functions
    """

    try
        # TODO: Implement the inclusion of Python data structures from system models here
        include(exp_config["simulations"]["data_structures"])
    catch err
        @error "Inclusion of the system model's data structures failed with the following error: " err
        exit(1)
    end

    random_simulation_name = first(setdiff(keys(exp_config["simulations"]), ("data_structures", "functions")))
    random_init_condition = eval(Symbol(exp_config["simulations"][random_simulation_name]["initial_conditions"]))
    generate_state_type(random_init_condition)

    println()
    @info "The following State type was generated and is available in the current scope:"
    dump(State)
    println()

    try
        # TODO: Implement the inclusion of Python functions from system models here
        include(exp_config["simulations"]["functions"])
    catch err
        @error "Inclusion of the system model's functions failed with the following error: " err
        exit(1)
    end

    n_threads = nthreads()
    @info "Running cadCAD.jl with $n_threads thread(s)."

    for simulation_name in keys(exp_config["simulations"])
        if simulation_name in ("data_structures", "functions")
            continue
        elseif exp_config["simulations"][simulation_name]["enabled"]
            @info "Running simulation $simulation_name..."
            # run_simulation(exp_config)
        else
            @info "Skipping simulation $simulation_name because it was disabled."
        end
    end
end

function exit_on_escalation()
    cadcad_id = getpid()

    @debug "This cadCAD process has PID: " cadcad_id

    # TODO: Add more OSs
    @static if Sys.islinux()
        if stat("/proc/$cadcad_id").uid == 0x0
            @error "Running cadCAD as a privileged process is forbidden."
            exit(1)
        end
    else
        @warn "Do not run cadCAD as a privileged process. Currently, there is no checking of that on your system."
    end
end

end
