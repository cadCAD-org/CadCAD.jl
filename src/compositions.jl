import Base: >

# Must overload > to broadcast NamedTuples into functions
function >(prev_block_result::NamedTuple{Vararg{DataType}}, block2::T) where {T<:Function}
    .
end