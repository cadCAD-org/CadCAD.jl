module cadCAD

include("spaces.jl")

using .Spaces

@space begin
    myname::String
    age::Int64
end

#println(fieldnames(State))

A = @NamedTuple begin
    a::Float64
    b::String
end
println(fieldnames(A))
end
