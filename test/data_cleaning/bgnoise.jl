@testset "background noise mask" begin
    for i in 1:10
        x = size(radiance_datacube)[1]
        y = size(radiance_datacube)[2]
        z = size(radiance_datacube)[4]
        rad = rand(20:100.0, x,y,1,z)
        clouds = rand(1:30, x,y,1,z)
        rad = Raster(rad, dims(radiance_datacube))
        clouds = Raster(clouds, dims(radiance_datacube))
        @test size(bgnoise_PSTT2021(rad,clouds,rand(0:0.9))) == (x,y)
    end
end