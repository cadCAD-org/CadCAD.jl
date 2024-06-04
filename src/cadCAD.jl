module cadCAD

include("spaces.jl")

# using .Spaces

# @space begin
#     myname::String
#     age::Int64
# end

# #println(fieldnames(State))

# A = @NamedTuple begin
#     a::Float64
#     b::String
# end
# println(fieldnames(A))

using Base.Threads, Base.Libc, Logging, TerminalLoggers
using .Simulation

const old_logger = global_logger(TerminalLogger(right_justify=120))

"""
cadCAD.jl v0.1.0
"""
function main()
    println(raw"""
                          _  ____    _    ____    _ _
             ___ __ _  __| |/ ___|  / \  |  _ \  (_) |
            / __/ _` |/ _` | |     / _ \ | | | | | | |
           | (_| (_| | (_| | |___ / ___ \| |_| | | | |
            \___\__,_|\__,_|\____/_/   \_\____(_)/ |_|
                                               |__/
          """)

    @info """
    \nStarting experiment $(exp_config["title"]) based on $toml_path
    With system model composed of:
    $(exp_config["simulations"]["data_structures"]) as the data structures
    and
    $(exp_config["simulations"]["functions"]) as the functions
    """

    n_threads = nthreads()
    @info "Running cadCAD.jl with $n_threads thread(s)."

    # TODO: Implement the entrypoint for the simulation

end

end
