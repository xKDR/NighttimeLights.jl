@testset "bgnoise_PSTT2021" begin
    @property max_examples=CHEAP function lit_iff_last_year_mean_above_threshold(c = cubes(maybe_missing(floats(0.0, 10.0)), ncfobs()),
                                                                              th = floats(0.0, 10.0))
        rad, ncf = c
        mask = bgnoise_PSTT2021(as_raster(rad), as_raster(ncf), th)
        last_year = size(rad, 3)-11:size(rad, 3)
        all(CartesianIndices(mask)) do ij
            lit = NighttimeLights.weighted_mean(rad[ij, last_year], ncf[ij, last_year]) > th
            isequal(mask[ij], lit ? 1 : missing)
        end
    end

    @property max_examples=CHEAP function ignores_earlier_months(c = cubes(radiance(), ncfobs(), radiance()))
        rad, ncf, other = c
        changed = copy(rad)
        changed[:, :, 1:end-12] = other[:, :, 1:end-12]
        isequal(bgnoise_PSTT2021(as_raster(rad), as_raster(ncf)), bgnoise_PSTT2021(as_raster(changed), as_raster(ncf)))
    end
end
