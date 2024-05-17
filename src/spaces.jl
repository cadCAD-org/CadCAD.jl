module Spaces

export generate_space_type, dimensions, inspect, name, isempty, isequivalent, EmptySpace,
    issubspace, isdisjoint, space_add, space_intersect, space_diff, space_complement,
    add, +, RealSpace, IntegerSpace, BitSpace

import Base: +

function generate_space_type(schema::NamedTuple, name::String, io::IO=stdout)
    state_signature = generate_space_signature(schema)

    if isnothing(state_signature)
        error("Invalid schema")
    else
        eval(space_factory(state_signature, name))
        println(io, "Generated space $name")
    end
end

function generate_space_type(schema::Dict{Symbol,DataType}, name::String, io::IO=stdout)
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
        struct $space
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

function dimensions(space::DataType)
    return Dict(zip(fieldnames(space), fieldtypes(space)))
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

function inspect(space::DataType)
    show(space)
end

function show(space::DataType, io::IO=stdout)
    println(io, "Space $(name(space)) has dimensions: ")
    pprint_dims(dimensions(space))
end

function name(space::DataType)
    return string(nameof(space))
end

function isempty(space::DataType)
    return fieldtypes(space) === ()
end

function isequivalent(space1::DataType, space2::DataType)
    return fieldtypes(space1) === fieldtypes(space2)
end

function issubspace(space1::DataType, space2::DataType)
    return fieldtypes(space1) ⊆ fieldtypes(space2)
end

function isdisjoint(space1::DataType, space2::DataType)
    return fieldtypes(space1) ∩ fieldtypes(space2) == ()
end

function add(spaces::DataType...)
    reduce(+, spaces)
end

function +(space1::DataType, space2::DataType)
    return space_add(space1, space2)
end

function space_add(space1::DataType, space2::DataType)
    return generate_space_type(merge(dimensions(space1), dimensions(space2)), "U_$(name(space1))_$(name(space2))")
end

function space_intersect(space1::DataType, space2::DataType)
    return generate_space_type(intersect(dimensions(space1), dimensions(space2)), "I_$(name(space1))_$(name(space2))")
end

function space_diff(space1::DataType, space2::DataType)
    return generate_space_type(setdiff(dimensions(space1), dimensions(space2)), "D_$(name(space1))_$(name(space2))")
end

generate_space_type((real=Float64,), "RealSpace", stderr)

generate_space_type((integer=Int128,), "IntegerSpace", stderr)

generate_space_type((bit=Bool,), "BitSpace", stderr)

generate_empty_space()

end
