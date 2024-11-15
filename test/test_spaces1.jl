module TestSpaces1

using CadCAD: Point, is_space, is_equivalent

@kwdef struct Cartesian <: Point
    x::Float64
    y::Float64
end

@kwdef struct Polar <: Point
    r::Float64
    phi::Float64
end

point1 = Cartesian(;
    x = 1.0,
    y = 2.0
)

point2 = Cartesian(;
    x = 2.0,
    y = 3.0
)

@assert !(point1 == point2)
@assert is_space(Cartesian)
@assert is_equivalent(Cartesian, Polar)

end
