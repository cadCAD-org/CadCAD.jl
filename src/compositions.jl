module Compositions

include("dynamics.jl")

using .Dynamics

import Base: >

function is_composable(block1::Function, block2::Function)::Bool
    return isequal(lower_codomain(block1), lower_codomain(block2))
end

function >(prev_block_result::Any, next_block::Function)
    return prev_block_result |> next_block
end

end

# Composability to be tested on a higher level, over the whole DSL string, before execution.
