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
    load_example()
    for i in 1:10
        x = rand(1:30)
        y = rand(1:30)
        z = rand(1:30)
        datacube = Raster(rand(84,155,123), Rasters.dims(radiance_datacube))
        clouds = rand(0:5, x, y, z)
        @test size(mark_missing(datacube, clouds)) == size(datacube)
    end
end