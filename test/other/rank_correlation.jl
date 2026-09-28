@testset "rank_correlation" begin
    for i in 1:1000
        len = rand(10:80)
        x = rand(1:100.0,len)
        y = rand(1:100.0,len)
        @test length(NighttimeLights.rank_correlation_test(x, y)) == 1
    end
    # t = r*sqrt((n-2)/(1-r^2)): r = 0.5, n = 72 gives t = 4.8305, one-tailed p = 3.876e-6
    @test NighttimeLights.t_test(72, 0.5) ≈ 3.876e-6 rtol = 1e-3
end