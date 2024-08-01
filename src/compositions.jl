module Compositions

include("dynamics.jl")

using .Dynamics

import Base: >

function is_composable(block1::T, block2::J)::Bool where {T <: Function, J <: Function}
    return isequal(lower_codomain(block1), lower_codomain(block2))
end

# Must overload > to broadcast NamedTuples into functions
function >(prev_block_result::NamedTuple{Vararg{DataType}}, block2::T) where {T <: Function}
    return block2(prev_block_result...)
end

end
