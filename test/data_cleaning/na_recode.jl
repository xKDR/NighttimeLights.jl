@testset "marking missings in image" begin
    for i in 1:10
        x = rand(1:30)
        y = rand(1:30)
        image = rand(1:10.0, x, y)
        image = convert(Array{Union{Float64, Missing}}, image)
        ncfobs = rand(0:5, x, y)
        @test size(NighttimeLights.na_recode_img(image, ncfobs)) == size(image) 
    end
end

@testset "marking missings in datacube" begin
    for i in 1:10
        x = size(radiance_datacube)[1]
        y = size(radiance_datacube)[2]
        z = size(radiance_datacube)[3]
        rad = rand(20:100.0, x,y,z)
        ncfobs = rand(0:3, x,y,z)
        rad = Raster(rad, dims(radiance_datacube))
        ncfobs = Raster(ncfobs, dims(radiance_datacube))
        @test size(na_recode(rad, ncfobs)) == size(rad)
    end
end