module MetaEngine

macro state_factory(schema::String)
    fields = map(x -> Meta.parse(x), split(schema))

    return quote
        struct State
            $(fields...)
            timestep::UInt64
            substep::UInt64

            function State($(fields...), timestep::UInt64, substep::UInt64)
                new($(fields...), timestep::UInt64, substep::UInt64)
            end

            State(;$(fields...), timestep::UInt64=1, substep::UInt64=1) = State($(fields...), timestep::UInt64, substep::UInt64)
        end
    end
end

function config_state(initial_conditions::Dict{String, Any})
    state_signature = ""

    for (variable, value) in initial_conditions
        type = typeof(value)
        state_signature *= "$variable::$type "
    end

    @MetaEngine.state_factory(state_signature)
end

end
