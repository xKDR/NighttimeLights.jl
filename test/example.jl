using GeoInterface

# load_example() already ran in runtests.jl
@testset "load_example" begin
    @test ndims(radiance_datacube) == 3 && dims(radiance_datacube) == dims(ncfobs_datacube)
    @test eltype(ncfobs_datacube) <: Integer && all(>=(0), ncfobs_datacube)
    @test length(mumbai_map) > 0 && all(!ismissing, mumbai_map.geometry)
    # every district lies on the radiance grid
    for g in mumbai_map.geometry
        @test length(crop(radiance_datacube[Ti = 1], to = g)) > 0
    end
end
