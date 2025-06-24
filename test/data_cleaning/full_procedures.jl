@testset "conventional cleaning" begin
@test size(PSTT2021_conventional(radiance_datacube, ncfobs_datacube)) == size(radiance_datacube)
end

@testset "PSTT2021 cleaning" begin
    @test size(PSTT2021(radiance_datacube, ncfobs_datacube)) == size(radiance_datacube)
end

@testset "complete cleaning" begin
    @test size(clean_complete(radiance_datacube, ncfobs_datacube)) == size(radiance_datacube)
end
