function test_func(x)
    max = maximum(skipmissing(x))
    return x.+ max
end

@testset "long_apply" begin
    for i in 1:10
        x = size(radiance_datacube)[1]
        y = size(radiance_datacube)[2]
        z = size(radiance_datacube)[4]
        rad = rand(20:100.0, x,y,1,z)
        rad = Raster(rad, dims(radiance_datacube))
        mask = rand(0:1, x, y)
        @test size(long_apply(test_func, rad, mask)) == size(rad)
    end
end