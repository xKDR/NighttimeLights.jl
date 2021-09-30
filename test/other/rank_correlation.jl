@testset "rank_correlation" begin
    for i in 1:1000
        len = rand(10:80)
        x = rand(1:100.0,len)
        y = rand(1:100.0,len)
        @test length(NighttimeLights.rank_correlation_test(x, y)) == 1
    end
end