@testset "weighted_mean" begin
    for i in 1:10
        len = rand(1:80)
        x = rand(1:100.0,len)
        y = rand(1:100.0,len)
        @test length(NighttimeLights.weighted_mean(x, y)) == 1
    end
end