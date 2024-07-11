module Compositions

include("dynamics.jl")

import Base: >

function is_composable(block1::T, block2::J) where {T<:Function,J<:Function}
    ...
end

# Must overload > to broadcast NamedTuples into functions
function >(prev_block_result::NamedTuple{Vararg{DataType}}, block2::T) where {T<:Function}
    ...
end

end
