@testset "removing outlier observations" begin
    for i in 1:1000
        len = rand(10:80)
        x = Array{Union{Float64, Missing}}(rand(1:100.0,len))
        x[rand(1:len)] = missing
        @test length(outlier_ts(x)) == len
    end
end

@testset "generating outlier mask" begin
    for i in 1:10
        x = rand(10:30)
        y = rand(10:30)
        z = rand(10:30)
        rad = Array{Union{Float64, Missing}}(rand(20:100.0, x, y,1, z))
        for j in 1:rand(1:20)
            rad[rand(1:x), rand(1:y),1, rand(1:z)] = missing
        end
        mask = rand(0:1, x, y)
        @test size(outlier_mask(rad, mask)) == (x, y)
    end
end