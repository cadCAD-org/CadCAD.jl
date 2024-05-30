module Spaces

export generate_space_type, dimensions, inspect, name, isempty, isequivalent, EmptySpace,
    issubspace, isdisjoint, space_add, space_intersect, space_diff, space_complement,
    unroll_schema, cartesian, power, add, +, *, ^, RealSpace, IntegerSpace, BitSpace, Space

import Base: +, *, ^

abstract type Space end

function generate_space_type(schema::NamedTuple, name::String, io::IO=stderr)
    state_signature = generate_space_signature(schema)

    if isnothing(state_signature)
        error("Invalid schema")
    else
        eval(space_factory(state_signature, name))
        println(io, "Generated space $name")
    end
end

function generate_space_type(schema::Dict{Symbol,DataType}, name::String, io::IO=stderr)
    state_signature = generate_space_signature(schema)

    if isnothing(state_signature)
        error("Invalid schema")
    else
        eval(space_factory(state_signature, name))
        println(io, "Generated space $name")
    end
end

function generate_empty_space()
    eval(space_factory("", "EmptySpace"))
end

function space_factory(state_signature::String, space_name::String)
    fields = map(x -> Meta.parse(x), split(state_signature))

    space = Symbol(space_name)

    return quote
        struct $space <: Space
            $(fields...)

            function $space($(fields...),)
                new($(fields...),)
            end

            $space(; $(fields...),) = $space($(fields...),)
        end
    end
end

function generate_space_signature(schema::Union{NamedTuple,Dict})
    state_signature = ""

    for (key, value) in pairs(schema)
        if isa(key, Symbol) && isa(value, DataType)
            state_signature *= "$key::$value "
        else
            return nothing
        end
    end
    return state_signature
end

function dimensions(space::Space)
    return Dict(zip(fieldnames(space), fieldtypes(space)))
end

function unroll_schema(space::Space)
    dims = dimensions(space)

    for (key, value) in dims.items()
        if typeof(value) <: DataType
            dims[key] = unroll_schema(value)
        end
    end

    return dims
end

function pprint_dims(dims::Dict, pre=1)
    todo = Vector{Tuple}()

    for (key, value) in dims
        if typeof(value) <: Dict
            push!(todo, (key, value))
        else
            println(join(fill(" ", pre)) * "$(repr(key)) => $(repr(value))")
        end
    end

    for (key, dims) in todo
        s = "$(repr(key)) => "
        println(join(fill(" ", pre)) * s)
        pprint_dims(dims, pre + 1 + length(s))
    end
end

function inspect(space::Space)
    show(space)
end

function show(space::Space, io::IO=stderr)
    println(io, "Space $(name(space)) has dimensions: ")
    pprint_dims(dimensions(space))
end

function name(space::Space)::String
    return string(nameof(space))
end

function isempty(space::Space)
    return fieldtypes(space) === ()
end

function isequivalent(space1::Space, space2::Space)
    return fieldtypes(space1) === fieldtypes(space2)
end

function issubspace(space1::Space, space2::Space)
    return fieldtypes(space1) ⊆ fieldtypes(space2)
end

function isdisjoint(space1::Space, space2::Space)
    return fieldtypes(space1) ∩ fieldtypes(space2) == ()
end

function add(spaces::Space...)
    reduce(+, spaces)
end

function +(space1::Space, space2::Space)
    return space_add(space1, space2)
end

function space_add(space1::Space, space2::Space)
    return generate_space_type(merge(dimensions(space1), dimensions(space2)), "U_$(name(space1))_$(name(space2))")
end

function *(space1::Space, space2::Space)
    return cartesian(space1, space2)
end

function cartesian(space1::Space, space2::Space)
    name1 = name(space1)
    name2 = name(space2)
    return generate_space_type((name1=space1, name2=space2), "$(name(space1))x$(name(space2))")
end

function ^(space::Space, n::Int)
    return power(space, n)
end

function power(space::Space, n::Int)
    return generate_space_type((name(space) => space for _ in 1:n), "$(name(space))^$n")
end

function space_intersect(space1::Space, space2::Space)
    return generate_space_type(intersect(dimensions(space1), dimensions(space2)), "I_$(name(space1))_$(name(space2))")
end

function space_diff(space1::Space, space2::Space)
    return generate_space_type(setdiff(dimensions(space1), dimensions(space2)), "D_$(name(space1))_$(name(space2))")
end

generate_space_type((real=Float64,), "RealSpace", stderr)

generate_space_type((integer=Int128,), "IntegerSpace", stderr)

generate_space_type((bit=Bool,), "BitSpace", stderr)

generate_empty_space()

end
