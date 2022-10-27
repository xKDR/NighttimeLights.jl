@testset "linear interpolation" begin
    for i in 1:10
        len = rand(10:80)
        x = Array{Union{Float64, Missing}}(rand(1:100.0,len))
        x[rand(1:len-5)] = missing
        @test length(na_interp_linear(x)) == len
    end
end