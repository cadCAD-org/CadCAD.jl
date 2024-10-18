module CadCAD

export run_exp

include("spaces.jl")

using .Spaces
using Logging, StaticArrays

"""
cadCAD.jl v0.0.2
"""
function intro()
    println(raw"""
      ____          _  ____    _    ____    _ _
     / ___|__ _  __| |/ ___|  / \  |  _ \  (_) |
    | |   / _` |/ _` | |     / _ \ | | | | | | |
    | |__| (_| | (_| | |___ / ___ \| |_| | | | |
     \____\__,_|\__,_|\____/_/   \_\____(_)/ |_|
                                         |__/ v0.0.2
          """)

    @info """
    \nStarting simultation...\n
    """
end

function run_exp(init_state::T, experiment_params::NamedTuple,
        pipeline::String) where {T <: Point}
    intro()

    pipeline_expr = pipeline_compile(pipeline)
    result_matrix = SVector{experiment_params.n_runs, Vector{T <: Point}}

    for i in 1:(experiment_params.n_runs)
        current_state = init_state
        result = Vector{T}(undef, experiment_params.n_steps)
        result[1] = current_state

        for j in 1:(experiment_params.n_steps)
            current_state = result[end] |> eval(pipeline_expr) # TODO
            result[j + 1] = current_state
        end

        result_matrix[i] = result
    end

    return result_matrix
end

function pipeline_compile(pipeline::String)::Expr
    return Meta.parse(pipeline)
end
end
