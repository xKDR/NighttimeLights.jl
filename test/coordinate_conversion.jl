@testset "Coordinate System" begin
    load_example()
    bbox = bounding_box(mumbai_map[1, :].geometry)
    geometry  = translate_geometry(INDIA_COORDINATE_SYSTEM, bbox)
    @test geometry.height >= 0
    @test geometry.width >= 0
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