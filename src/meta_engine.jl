module MetaEngine

export generate_state_type, State

function generate_state_type(initial_conditions::NamedTuple)
    eval(state_factory(initial_conditions))
end

function state_factory(initial_conditions::NamedTuple)
    state_signature = generate_state_signature(initial_conditions)

    fields = map(x -> Meta.parse(x), split(state_signature))

    return quote
        struct State
            $(fields...)
            timestep::Int64
            substep::Int64

            function State($(fields...), timestep::Int64, substep::Int64)
                new($(fields...), timestep::Int64, substep::Int64)
            end

            State(; $(fields...), timestep::Int64 = 1, substep::Int64 = 1) = State($(fields...), timestep::Int64 = 1, substep::Int64 = 1)
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

end
