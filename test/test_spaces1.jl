module TestSpaces1

using CadCAD: Point, is_space, is_equivalent, is_equivalent_underlying_space

@kwdef struct Cartesian <: Point
    x::Float64
    y::Float64
end

@kwdef struct Cartesian2 <: Point
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

point3 = Cartesian(;
x = 1.0,
y = 2.0
)

point4 = Polar(;
r=1,
phi=60)

@assert point1 != point2
@assert point1 == point3
@assert point1 != point4
@assert is_space(Cartesian)
@assert is_equivalent(Cartesian, Cartesian)
@assert is_equivalent(Cartesian, Cartesian2)
@assert !(is_equivalent(Cartesian, Polar))
@assert is_equivalent_underlying_space(point1, point2)
@assert !(is_equivalent_underlying_space(point1, point4))

end
