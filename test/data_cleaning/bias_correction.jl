@testset "bias correction for time series" begin
    for i in 1:10
        rad = Array{Union{Float64, Missing}}(rand(1:100.0, 100))
        for j in 1:10   
            rad[rand(1:100)] = missing
        end
        clouds = rand(1:31, 100)
        @test length(NighttimeLights.PSTT2021_biascorrect_pixel(rad, clouds)) == length(rad)
    end
end

@testset "bias correction for datacube" begin
    for i in 1:10
        x = size(radiance_datacube)[1]
        y = size(radiance_datacube)[2]
        z = size(radiance_datacube)[4]
        
        rad = Array{Union{Float64, Missing}}(rand(20:100.0, x, y, 1, z))
        for j in 1:rand(1:20)
            rad[rand(1:x), rand(1:y),1,  rand(1:z)] = missing
        end
        rad = Raster(rad, dims(radiance_datacube))
        clouds = rand(1:30, x,y,1,z)
        clouds = Raster(clouds, dims(radiance_datacube))
        mask = rand(0:1, x, y)
        @test size(PSTT2021_biascorrect(rad, clouds, mask)) == (x, y, 1, z)
    end
end

