@testset "Coordinate" begin
    for i in 1:10
        @test typeof(Coordinate(rand(-10.0:10.0), rand(-10.0:10.0))) == Coordinate

    end
end

@testset "Coordinate System" begin
    for i in 1:10
        top_left = Coordinate(rand(30.0:50.0), rand(0:10.0))
        bottom_right = Coordinate(rand(0.0:30.0), rand(10.0:20.0))
        height = rand(1:1000)
        width = rand(1:1000)
        system = CoordinateSystem(top_left, bottom_right, height, width)
        @test typeof(system) == CoordinateSystem
    end
end