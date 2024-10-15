module CadCAD

export run

include("spaces.jl")

using .Spaces
using Logging, StructArrays, StaticArrays

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

function run(init_state::T, experiment_params::Dict{String, Int},
        pipeline::String) where {T <: Space}
    intro()

    pipeline_expr = pipeline_compile(pipeline)
    result_matrix = SVector{experiment_params["n_runs"], StructArray{T <: Space}}

    for _ in 1:experiment_params["n_runs"]
        current_state = init_state
        result = StructArray{T <: Space}
        push!(result, current_state)

        for _ in 1:experiment_params["n_steps"]
            current_state = eval(Symbol(result[end]) * pipeline_expr)
            push!(result, current_state)
        end

        push!(result_matrix, result)
    end

    return result_matrix
end

function pipeline_compile(pipeline::String)::Expr
    return Meta.parse(pipeline)
end
end
