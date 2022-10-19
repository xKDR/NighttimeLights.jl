@testset "conventional cleaning" begin
@test size(PSTT2021_conventional(radiance_datacube, clouds_datacube)) == size(radiance_datacube)
end

@testset "PSTT2021 cleaning" begin
    @test size(PSTT2021(radiance_datacube, clouds_datacube)) == size(radiance_datacube)
end
