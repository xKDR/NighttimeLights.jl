@testset "marking missings in image" begin
    for i in 1:10
        x = rand(1:30)
        y = rand(1:30)
        image = rand(1:10.0, x, y)
        image = convert(Array{Union{Float64, Missing}}, image)
        clouds = rand(0:5, x, y)
        @test size(NighttimeLights.mark_missing_img(image, clouds)) == size(image) 
    end
end

@testset "marking missings in datacube" begin
    for i in 1:10
        x = size(radiance_datacube)[1]
        y = size(radiance_datacube)[2]
        z = size(radiance_datacube)[4]
        rad = rand(20:100.0, x,y,1,z)
        clouds = rand(0:3, x,y,1,z)
        rad = Raster(rad, dims(radiance_datacube))
        clouds = Raster(clouds, dims(radiance_datacube))
        @test size(mark_missing(rad, clouds)) == size(rad)
    end
end