@testset "testing counter_nan" begin
    for i in 1:10
        x = rand(10:30)
        rad = rand(20:100.0, x)
        nans = rand(1:20)
        @test length(NighttimeLights.detrend_ts(rad)) == x 
    end
end
