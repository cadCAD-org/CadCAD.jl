using JET

@testset "JET.jl" begin
    JET.report_package(
        CadCAD;
        ignored_modules = (AnyFrameModule(Base),)
    )
end

# TODO: Improve this with:
# https://aviatesk.github.io/JET.jl/stable/tutorial/#Analyze-scripts-and-apps-by-using-a-main-function
