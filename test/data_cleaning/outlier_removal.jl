@testset "removing outlier observations" begin
    for i in 1:1000
        len = rand(10:80)
        x = Array{Union{Float64, Missing}}(rand(1:100.0,len))
        x[rand(1:len)] = missing
        @test length(outlier_ts(x)) == len
    end
end

@testset "generating outlier mask" begin
    load_example()
    for i in 1:10
        x = size(radiance_datacube)[1]
        y = size(radiance_datacube)[2]
        z = size(radiance_datacube)[4]
        
        rad = Array{Union{Float64, Missing}}(rand(20:100.0, x, y, 1, z))
        for j in 1:rand(1:20)
            rad[rand(1:x), rand(1:y),1,  rand(1:z)] = missing
        end
        rad = Raster(rad, dims(radiance_datacube))
        mask = rand(0:1, x, y)
        @test size(outlier_mask(rad, mask)) == (x, y)
    end
end