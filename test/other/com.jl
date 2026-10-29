@testset "centre_of_mass" begin
    @property max_examples=CHEAP function single_lit_pixel_is_the_centre(c = cubes(Data.Just(0.0); dims = map(d -> (d[1], d[2], 1), cube_dims), max_size = 9),
                                                                      i = Data.Integers(1, 3), j = Data.Integers(1, 3), v = floats(0.1, 1e4))
        img = as_raster(only(c))
        i, j = min(i, size(img, 1)), min(j, size(img, 2))
        img[i, j, 1] = v
        collect(centre_of_mass(img)) == [dims(img, X)[i], dims(img, Y)[j]]
    end

    @property max_examples=CHEAP function invariant_to_scaling_radiance(c = cubes(floats(0.0, 100.0); dims = map(d -> (d[1], d[2], 1), cube_dims), max_size = 9),
                                                                     k = floats(0.5, 100.0))
        img = only(c)
        assume!(any(>(0), img))
        # an index centre on an exact .5 can round either way once k adds rounding error
        w = img[:, :, 1]
        centre(idx) = sum(idx .* w) / sum(w)
        assume!(all(x -> abs(x - floor(x) - 0.5) > 1e-6, (centre(axes(w, 1)), centre(axes(w, 2)'))))
        centre_of_mass(as_raster(img)) == centre_of_mass(as_raster(k .* img))
    end

    @property max_examples=CHEAP function float16_does_not_overflow(c = cubes(floats(0.0, 60000.0); dims = map(d -> (d[1], d[2], 1), cube_dims), max_size = 9))
        img16 = Float16.(only(c))
        assume!(any(>(0), img16))
        centre_of_mass(sparse(img16[:, :, 1]), dims(as_raster(img16))) == centre_of_mass(sparse(Float64.(img16[:, :, 1])), dims(as_raster(img16)))
    end

    img = view(radiance_datacube, Ti(1))
    @test isapprox(centre_of_mass(sparse(Array(img)[:, :, 1]), dims(img)), [72.88333535640002, 19.070832885899996])
end
