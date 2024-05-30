module Systems

export run_simulation

include("spaces.jl")

using .Spaces, StructArrays, StaticArrays

function run_simulation(init_state::T, experiment_params::Dict{String,Int}, pipeline::String) where {T<:Space}
    if !validate(pipeline)
        error("Invalid pipeline")
    else
        pipeline_expr = jl_compile(pipeline)
    end

    result_matrix = SVector{experiment_params["iteration_n"],StructArray{T<:Space}}

    for _ in 1:experiment_params["iteration_n"]
        current_state = init_state
        result = StructArray{T<:Space}
        push!(result, current_state)

        for _ in 1:experiment_params["steps"]
            #TODO: Inject initial state into pipeline
            current_state = eval(pipeline_expr)
            push!(result, current_state)
        end

        push!(result_matrix, result)
    end

    return result_matrix
end

function validate(pipeline::String)::Bool
    # TODO: Acceptance criteria for a DSL string
end

function jl_compile(pipeline::String)::Expr
    return Meta.parse(pipeline)
end

end
