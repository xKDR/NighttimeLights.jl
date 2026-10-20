@testset "replace_negative" begin
    @property max_examples=CHEAP function drops_negatives_in_place(c = cubes(maybe_missing(radiance())))
        cube = as_raster(only(c))
        before = copy(Array(cube))
        out = replace_negative(cube)
        out === cube && isequal(Array(out), map(x -> !ismissing(x) && x < 0 ? missing : x, before))
    end

    @property max_examples=CHEAP function custom_replacement(c = cubes(radiance()))
        cube = only(c)
        isequal(Array(replace_negative(as_raster(copy(cube)); replacement = 0.0)), ifelse.(cube .< 0, 0.0, cube))
    end
end

@testset "replace_above" begin
    expected(x, ceiling, T) = ismissing(x) || x > ceiling ? missing : convert(T, x)

    @property max_examples=CHEAP function drops_values_above_ceiling(c = cubes(maybe_missing(radiance())), ceiling = floats(0.0, 200.0))
        cube = as_raster(only(c))
        before = copy(Array(cube))
        out = replace_above(cube, ceiling)
        isequal(Array(cube), before) &&                       # input untouched
            eltype(out) == Union{Missing, Float64} &&
            isequal(Array(out), expected.(before, ceiling, Float64))
    end

    @property max_examples=CHEAP function float16_conversion_stays_finite(c = cubes(floats(-5.0, 1e6)))
        cube = only(c)
        out = replace_above(as_raster(cube), 8000; T = Float16)
        eltype(out) == Union{Missing, Float16} &&
            all(x -> ismissing(x) || isfinite(x), out) &&
            isequal(Array(out), expected.(cube, 8000, Float16))
    end
end
