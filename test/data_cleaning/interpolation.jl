@testset "linear interpolation" begin
    for i in 1:10
        len = rand(10:80)
        x = rand(1:100.0,len)
        x[rand(1:len-5)] = missing
        @test length(linear_interpolation(x)) == len
    end
end