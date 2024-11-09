module TestSpaces1


using CadCAD: Point

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

println(point1 == point2)

end