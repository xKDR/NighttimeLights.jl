load_example()
@testset "conventional cleaning" begin
@test sizeof(conventional_cleaning(radiance_datacube, clouds_datacube)) == sizeof(radiance_datacube)
end

@testset "PatnaikSTT2021 cleaning" begin
    @test sizeof(PatnaikSTT2021(radiance_datacube, clouds_datacube)) == sizeof(radiance_datacube)
end
