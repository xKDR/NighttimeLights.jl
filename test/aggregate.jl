@testset "aggregate" begin
for i in 1:10
    testimage = rand(1:10.0, 10, 10)
    testmask = rand(0:1, 10, 10)
    @test aggregate(testimage, testmask) >= 0  
end
end

@testset "aggregate_timeseries" begin
for i in 1:10
    testcube = rand(1:10.0, 10, 10, 10)
    testmask = rand(0:1, 10, 10)
    @test length(aggregate_timeseries(testcube, testmask)) == size(testcube)[3]  
end
end