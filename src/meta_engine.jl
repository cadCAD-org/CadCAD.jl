module MetaEngine

macro make_state(schema::String)
    fields_list = split(schema) 
    return quote
        struct State
            $(fields...)
            function State($(fields...))
                new($(fields...))
            end
        end
    end
end

function state_impl(expr::String)
    dump(expr)
    expr
end

end
