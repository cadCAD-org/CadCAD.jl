export generate_state_signature, @state_factory

macro state_factory(signature::Union{Symbol,String})
    schema = eval(signature)
    fields = map(x -> Meta.parse(x), split(schema))

    return quote
        struct State
            $(fields...)
            timestep::Int64
            substep::Int64

            function State($(fields...), timestep::Int64, substep::Int64)
                new($(fields...), timestep::Int64, substep::Int64)
            end

            State(;$(fields...), timestep::Int64=1, substep::Int64=1) = State($(fields...), timestep::Int64, substep::Int64)
        end
    end
end

function generate_state_signature(initial_conditions::NamedTuple)
    state_signature = ""

    for (variable, value) in pairs(initial_conditions)
        type = typeof(value)
        state_signature *= "$variable::$type "
    end

    return state_signature
end
