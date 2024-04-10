module Spaces

export @space

macro space(ex)
    Meta.isexpr(ex, :block) || throw(ArgumentError("@space expects a begin...end block"))
    decls = filter(e -> !(e isa LineNumberNode), ex.args)
    all(e -> Meta.isexpr(e, :(::)), decls) || throw(ArgumentError("@space must contain a sequence of name::type expressions"))
    vars = [QuoteNode(e isa Symbol ? e : e.args[1]) for e in decls]
    println(vars)
    types = [e isa Symbol ? :Any : e.args[2] for e in decls]
    println(types)
    space_dims = ""
    for (var, type) in zip(vars, types)
        space_dims *= "$var::$type "
    end
    println(split(space_dims))
    println([Meta.parse(x) for x in split(space_dims)])
    space_quote = quote
        struct State
            $(split(space_dims)...)
        end
    end
    println(space_quote)
    eval(space_quote)
end

macro space(ex)


end

end
