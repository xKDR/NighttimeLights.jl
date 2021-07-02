@testset "marking nans in image" begin
    for i in 1:10
        x = rand(1:30)
        y = rand(1:30)
        image = rand(1:10.0, x, y)
        clouds = rand(0:5, x, y)
        @test size(mark_nan(image, clouds)) == size(image) 
    end
end

@testset "marking nans in datacube" begin
    for i in 1:10
        x = rand(1:30)
        y = rand(1:30)
        z = rand(1:30)
        datacube = rand(1:10.0, x, y, z)
        clouds = rand(0:5, x, y, z)
        @test size(mark_nan(datacube, clouds)) == size(datacube)
    end
end