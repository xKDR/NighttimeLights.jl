@testset "bias correction for time series" begin
    for i in 1:10
        rad = Array{Union{Float64, Missing}}(rand(1:100.0, 100))
        for j in 1:10   
            rad[rand(1:100)] = missing
        end
        clouds = rand(1:31, 100)
        @test length(bias_correction(rad, clouds)) == length(rad)
    end
end


@testset "bias correction for datacube" begin
    for i in 1:10
        x = rand(10:30)
        y = rand(10:30)
        z = rand(10:30)
        rad = Array{Union{Float64, Missing}}(rand(20:100.0, x, y, z))
        for j in 1:rand(1:20)
            rad[rand(1:x), rand(1:y), rand(1:z)] = missing
        end
        clouds = rand(1:30, x, y, z)
        mask = rand(0:1, x, y)
        @test size(bias_correction(rad, clouds, mask)) == (x, y, z)
    end
end

