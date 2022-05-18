@testset "aggregate" begin
    for i in 1:10
        testimage = rand(1:10.0, 10, 10)
        testmask = rand(0:1, 10, 10)
        @test NighttimeLights.aggregate(testimage, testmask) >= 0  
    end
    end

@testset "aggregate" begin
    A = reshape(collect(1:1000), (10, 10, 10))
    function bin(x)
        if x%2 == 0 
            return 1
        else return 0 
        end
    end
    mask = bin.(A[:,:,1])
    @test aggregate_timeseries(A, mask) ≈ [2550.0, 7550.0, 12550.0, 17550.0, 22550.0, 27550.0, 32550.0, 37550.0, 42550.0,
   47550.0]
 
end
    @testset "aggregate_timeseries" begin
    for i in 1:10
        testcube = rand(1:10.0, 10, 10, 10)
        testmask = rand(0:1, 10, 10)
        @test length(aggregate_timeseries(testcube, testmask)) == size(testcube)[3]  
    end
end 

    @testset "aggregate dataframe" begin
        load_example()
        df = aggregate_dataframe(MUMBAI_COORDINATE_SYSTEM, radiance_datacube, mumbai_map)
        @test nrow(df) > 0 
        df = aggregate_dataframe(MUMBAI_COORDINATE_SYSTEM, radiance_datacube, mumbai_map, Date(2012), Month(1))
        @test nrow(df) > 0 
        df = aggregate_per_area_dataframe(MUMBAI_COORDINATE_SYSTEM, radiance_datacube, mumbai_map, 15)
        @test nrow(df) > 0 
        df = aggregate_per_area_dataframe(MUMBAI_COORDINATE_SYSTEM, radiance_datacube, mumbai_map, Date(2012), Month(1), 15)
        @test nrow(df) > 0 
    end