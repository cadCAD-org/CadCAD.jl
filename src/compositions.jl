module Compositions

include("dynamics.jl")

using .Dynamics
using .Spaces: Point, dimensions, cartesian

import Base: >, |

function is_composable(block1::Function, block2::Function)::Bool
    return isequal(lower_codomain(block1), lower_codomain(block2))
end

function >(prev_block_result::Point, next_block::Function)
    return next_block(prev_block_result...)
end

function |(first_block_result::Point, second_block_result::Point)
    return joinpoint(first_block_result, second_block_result)
end

function joinpoint(first_pt::Point, second_pt::Point)
    first_dims = typeof(first_pt)
    second_dims = typeof(second_pt)

    cartesian(first_dims, second_dims, "Joined$(name(first_dims))$(name(second_dims))")
end

function splitpoint(first_pt::Point, second_pt::Point)
end

end

# Composability to be tested on a higher level, over the whole DSL string, before execution.
