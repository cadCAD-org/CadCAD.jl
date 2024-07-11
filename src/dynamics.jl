# Blocks are regular Julia functions with the following structure and added API:
# function myblock(dom1::RealSpace, dom2::IntegerSpace, codomain::SomeCompositeSpace)
#     ...
# end

module Dynamics

export domain, codomain, inspect_blk

function domain(block::T) where {T<:Function}
    return delete!(type_dict(block), "codomain")
end

function codomain(block::T) where {T<:Function}
    return Dict("codomain" => type_dict(block)["codomain"])
end

function inspect_blk(block::T) where {T<:Function}
    return methods(block).ms[1]
end

function type_dict(block::T) where {T<:Function}
    str_types = Base.arg_decl_parts(first(methods(block)))[2]
    svec_types = methods(block).ms[1].sig.parameters
    result = Dict(domain_name[1] => type_obj for (domain_name, type_obj) in zip(str_types, svec_types))
    return delete!(result, "")
end

end
