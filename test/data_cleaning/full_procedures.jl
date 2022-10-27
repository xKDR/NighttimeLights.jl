@testset "conventional cleaning" begin
@test size(PSTT2021_conventional(radiance_datacube, clouds_datacube)) == size(radiance_datacube)
end

@testset "PSTT2021 cleaning" begin
    @test size(PSTT2021(radiance_datacube, clouds_datacube)) == size(radiance_datacube)
end

@testset "complete cleaning" begin
    @test size(clean_complete(radiance_datacube, clouds_datacube; bgnoise_clean = true)) == size(radiance_datacube)
    @test size(clean_complete(radiance_datacube, clouds_datacube; bgnoise_clean = false)) == size(radiance_datacube)
end
