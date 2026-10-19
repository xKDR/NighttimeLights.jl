const lit_or_dark = Data.SampledFrom([1, missing])

@testset "long_apply" begin
    f(ts) = 2 .* ts .+ 1

    @property max_examples=CHEAP function applies_only_inside_mask(cm = cubes(maybe_missing(radiance()), lit_or_dark))
        cube, m = cm
        mask = m[:, :, 1]
        out = long_apply(f, as_raster(copy(cube)), mask)
        all(CartesianIndices(mask)) do ij
            expected = ismissing(mask[ij]) ? cube[ij, :] : f(cube[ij, :])
            isequal(out[ij, :], expected)
        end
    end

    @property max_examples=CHEAP function default_mask_applies_everywhere(c = cubes(radiance()))
        cube = only(c)
        isequal(Array(long_apply(f, as_raster(copy(cube)))), f(cube))
    end
end

@testset "apply_mask" begin
    @property max_examples=CHEAP function masks_by_multiplication(cm = cubes(maybe_missing(radiance()), lit_or_dark))
        cube, m = cm
        mask = m[:, :, 1]
        isequal(Array(apply_mask(as_raster(cube), mask)), mask .* cube)
    end

    @property max_examples=CHEAP function default_mask_is_identity(c = cubes(maybe_missing(radiance())))
        cube = only(c)
        isequal(Array(apply_mask(as_raster(cube))), cube)
    end
end
