module MetaEngine

macro state_factory(schema::String)
    fields = map(x -> Meta.parse(x), split(schema))
    return quote
        struct State
            $(fields...)
            function State($(fields...))
                new($(fields...))
            end
        end
    end
end

end
