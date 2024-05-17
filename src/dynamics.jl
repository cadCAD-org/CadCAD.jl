# Blocks are regular Julia functions with the following structure and added API:
# function myblock(dom1::RealSpace, dom2::IntegerSpace)::NamedTuple{(:codom1, :codom2), Tuple{IntegerSpace, IntegerSpace}}
#     ...
# end

module Dynamics

function domain(block::T) where {T<:Function}
    return Base.arg_decl_parts(first(methods(block)))[2][2:end]
end

# methods(func).ms[1].sig.parameters[2:end] to get domain as types
# return_types may be brittle
function codomain(block::T) where {T<:Function}
    return Base.return_types(block, methods(block).ms[1].sig.parameters[2:end])[1]
end

function iscomposable(block1::T, block2::T) where {T<:Function}
    return codomain(block1) == domain(block2)
end

end
