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

@testset "Conversion functions" begin
    @test lat_to_row(INDIA_COORDINATE_SYSTEM, 19.6) == 4296
    @test long_to_column(INDIA_COORDINATE_SYSTEM, 73.33) == 1299 
    @test isapprox(row_to_lat(INDIA_COORDINATE_SYSTEM, 100), 37.083325)
    @test isapprox(column_to_long(INDIA_COORDINATE_SYSTEM, 100), 68.333326760)
    @test coordinate_to_image(INDIA_COORDINATE_SYSTEM, Coordinate(19.49907, 72.721252)) == [4320, 1153]
    @test isapprox(image_to_coordinate(INDIA_COORDINATE_SYSTEM, [4320, 1153]).latitude, Coordinate(19.49964, 72.720827).latitude)
    @test isapprox(image_to_coordinate(INDIA_COORDINATE_SYSTEM, [4320, 1153]).longitude, Coordinate(19.49964, 72.720827).longitude)
    @test translate_geometry(INDIA_COORDINATE_SYSTEM, Coordinate(19.49907, 72.721252), Coordinate(18.849475, 73.074187)) == MUMBAI_COORDINATE_SYSTEM
end