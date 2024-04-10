module Spaces

export generate_space_type

function generate_space_type(initial_conditions::NamedTuple, name::String)
    eval(space_factory(initial_conditions, name))
end

function space_factory(initial_conditions::NamedTuple, space::String)
    state_signature = generate_state_signature(initial_conditions)

    fields = map(x -> Meta.parse(x), split(state_signature))

    sspace = Symbol(space)

    return quote
        struct $sspace
            $(fields...)

            function $sspace($(fields...),)
                new($(fields...),)
            end

            $sspace(; $(fields...),) = $sspace($(fields...),)
        end
    end
end

function generate_state_signature(initial_conditions::NamedTuple)
    state_signature = ""

    for (variable, value) in pairs(initial_conditions)
        state_signature *= "$variable::$value "
    end

    return state_signature
end

end