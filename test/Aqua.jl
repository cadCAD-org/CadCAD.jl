using Aqua

# https://juliatesting.github.io/Aqua.jl/stable/test_all/

@testset "Aqua.jl" begin
    Aqua.test_all(
        CadCAD;
    )
end
