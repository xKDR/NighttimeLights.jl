@testset "testing size" begin
    for i in 1:10
        x = rand(10:30)
        y = rand(10:30)
        z = rand(10:30)
        rad = rand(20:100.0, x,y,z)
        clouds = rand(1:30, x,y,z)
        mask = rand(0:1,x,y)
        @test size(background_noise_mask(rad,clouds,rand(0:0.9))) == (x,y)
    end
end