module Spaces

export dimensions, inspect_space, name, is_empty, is_equivalent,
       EmptySpace, is_subspace, is_disjoint, space_add, space_intersect,
       IntegerSpace, BitSpace, space_diff, RealSpace,
       unroll_schema, cartesian, power, add, +, *, ^, Point

import Base: +, *, ^, ==, ∩, -

#using Printf

abstract type Point end

#= macro space(ex)
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
end =#

# Factory methods

#function generate_space_type(
#        schema::NamedTuple, name::String, io::IO = stderr, debug = false)
#    state_signature = generate_space_signature(schema)
#
#    if isnothing(state_signature)
#        error("Invalid schema")
#    else
#        eval(space_factory(state_signature, name))
#        if debug
#            println(io, "Generated space $name")
#        end
#    end
#end
#
#function generate_space_type(
#        schema::Dict{Symbol, DataType}, name::String, io::IO = stderr, debug = false)
#    state_signature = generate_space_signature(schema)
#
#    if isnothing(state_signature)
#        error("Invalid schema")
#    else
#        eval(space_factory(state_signature, name))
#        if debug
#            println(io, "Generated space $name")
#        end
#    end
#end
#
#function generate_empty_space()
#    eval(space_factory("", "EmptySpace"))
#end
#
#function space_factory(state_signature::String, space_name::String)
#    fields = map(x -> Meta.parse(x), split(state_signature))
#
#    space = Symbol(space_name)
#
#    return quote
#        struct $space <: Space
#            $(fields...)
#
#            function $space($(fields...),)
#                new($(fields...),)
#            end
#        end
#    end
#end
#
#function generate_space_signature(schema::Union{NamedTuple, Dict})
#    state_signature = ""
#
#    for (key, value) in pairs(schema)
#        if isa(key, Symbol) && isa(value, DataType)
#            state_signature *= "$key::$value "
#        else
#            return nothing
#        end
#    end
#    return state_signature
#end

# Informational methods

function isspace(space::DataType)::Bool
    return isstructtype(space) && !ismutabletype(space) && !(Any in fieldtypes(space))
end

function dimensions(space::DataType)::Dict{Symbol, DataType}
    if !isspace(space)
        error("$space is not a space")
    end

    return Dict(zip(fieldnames(space), fieldtypes(space)))
end

function gen_unrolled_schema(space::DataType)::Dict{Symbol, Union{DataType, Dict}}
    if !isspace(space)
        error("$space is not a space")
    end

    dims = dimensions(space)
    new_dict = Dict()
    for (key, value) in dims
        if value <: Space
            new_dict[key] = gen_unrolled_schema(value)
        else
            new_dict[key] = value
        end
    end
    return new_dict
end

function unroll_schema(space::DataType)
    if !isspace(space)
        error("$space is not a space")
    end

    pprint_dims(gen_unrolled_schema(space))
end

function pprint_dims(dims::Dict, pre = 1)
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

function inspect_space(space::DataType)
    if !isspace(space)
        error("$space is not a space")
    end

    show(space)
end

function show(space::DataType, io::IO = stderr)
    if !isspace(space)
        error("$space is not a space")
    end

    println(io, "Space $(name(space)) has dimensions: ")
    pprint_dims(dimensions(space))
end

function name(space::DataType)::String
    if !isspace(space)
        error("$space is not a space")
    end

    return string(nameof(space))
end

function is_empty(space::DataType)::Bool
    if !isspace(space)
        error("$space is not a space")
    end

    return schema_size(space) == 0
end

function is_shallow(space::DataType)::Bool
    if !isspace(space)
        error("$space is not a space")
    end

    return all(value -> !(value isa Space), values(dimensions(space)))
end

function ==(space1::DataType, space2::DataType)::Bool
    if !isspace(space1) || !isspace(space2)
        error("Spaces were not provided")
    end

    return is_equivalent(space1, space2)
end

function is_equivalent(
        space1::DataType, space2::DataType)::Bool
    if !isspace(space1) || !isspace(space2)
        error("Spaces were not provided")
    end

    return fieldtypes(space1) == fieldtypes(space2)
end

function ⊂(space1::DataType, space2::DataType)::Bool
    if !isspace(space1) || !isspace(space2)
        error("Spaces were not provided")
    end

    return issubspace(space1, space2)
end

function issubspace(space1::DataType, space2::DataType)::Bool
    if !isspace(space1) || !isspace(space2)
        error("Spaces were not provided")
    end

    return space1 in fieldtypes(space2)
end

function isdisjoint(space1::DataType, space2::DataType)::Bool
    if !isspace(space1) || !isspace(space2)
        error("Spaces were not provided")
    end

    return length(intersect(dimensions(space1), dimensions(space2))) == 0
end

function schema_size(space::DataType)::UInt
    if !isspace(space)
        error("$space is not a space")
    end

    return fieldcount(space)
end

function dim_intersect(space1::DataType, space2::DataType)
    if !isspace(space1) || !isspace(space2)
        error("Spaces were not provided")
    end

    return intersect(dimensions(space1), dimensions(space2))
end

# Operational methods

function add()
    error("No spaces to add")
end

function add(spaces::DataType...)
    reduce(+, spaces)
end

function +(space1::DataType, space2::DataType)::DataType
    if !isspace(space1) || !isspace(space2)
        error("Spaces were not provided")
    end

    return space_add(space1, space2, "$(name(space1))+$(name(space2))")
end

function space_add(
        space1::DataType, space2::DataType, name::String)
    if !isspace(space1) || !isspace(space2)
        error("Spaces were not provided")
    end

    if isempty(dim_intersect(space1, space2))
        return generate_space_type(merge(dimensions(space1), dimensions(space2)), "$name")
    end

    new_dims = deepcopy(dimensions(space1))
    for (key, value) in dimensions(space2)
        if haskey(new_dims, key)
            new_key_name::String = @sprintf "%s_from_%s" key nameof(space2)
            new_key = Symbol(new_key_name)
            new_dims[new_key] = value
        else
            new_dims[key] = value
        end
    end
    return generate_space_type(new_dims, "$name")
end

function *(space1::DataType, space2::DataType)
    if !isspace(space1) || !isspace(space2)
        error("Spaces were not provided")
    end

    return cartesian(space1, space2, "$(name(space1))x$(name(space2))")
end

"""
    cartesian(
        space1::Type{T}, space2::Type{J}, name::String) where {T <: Space, J <: Space}

[docs]

# Example

```jldoctest
julia> ...
[...]
```
"""
function cartesian(
        space1::DataType, space2::DataType, name::String)
    if !isspace(space1) || !isspace(space2)
        error("Spaces were not provided")
    end

    name1 = name(space1)
    name2 = name(space2)
    return generate_space_type((name1 = space1, name2 = space2), "$name")
end

function ^(space::DataType, n::Int)
    if !isspace(space)
        error("$space is not a space")
    end

    return power(space, n, "$(name(space))^$n")
end

function power(space::DataType, n::Int, name::String)
    if !isspace(space)
        error("$space is not a space")
    end

    return generate_space_type((name(space) => space for _ in 1:n), "$name")
end

function ∩(space1::DataType, space2::DataType)
    if !isspace(space1) || !isspace(space2)
        error("Spaces were not provided")
    end

    return space_intersect(space1, space2, "$(name(space1))∩$(name(space2))")
end

function space_intersect(
        space1::DataType, space2::DataType, name::String)
    if !isspace(space1) || !isspace(space2)
        error("Spaces were not provided")
    end

    return generate_space_type(intersect(dimensions(space1), dimensions(space2)), "$name")
end

function -(space1::DataType, space2::DataType)
    if !isspace(space1) || !isspace(space2)
        error("Spaces were not provided")
    end

    return space_diff(space1, space2, "$(name(space1))-$(name(space2))")
end

function space_diff(
        space1::DataType, space2::DataType, name::String)
    if !isspace(space1) || !isspace(space2)
        error("Spaces were not provided")
    end

    return generate_space_type(setdiff(dimensions(space1), dimensions(space2)), "$name")
end

end

# Built-in space types

struct EmptySpace <: Point end

@kwdef struct RealSpace <: Point
    real::Float64
end

@kwdef struct IntegerSpace <: Point
    integer::Int128
end

@kwdef struct BitSpace <: Point
    bit::Bool
end
