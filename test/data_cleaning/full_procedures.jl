load_example()
@testset "conventional cleaning" begin
@test size(conventional_cleaning(radiance_datacube, clouds_datacube)) == size(radiance_datacube)
end

@testset "PatnaikSTT2021 cleaning" begin
    @test size(PatnaikSTT2021(radiance_datacube, clouds_datacube)) == size(radiance_datacube)
end
