@testset "annular_ring" begin
    img = view(radiance_datacube, Ti(At(DateTime(2012, 6))))
    res = 15
    lats = floats(19.0, 19.12)
    longs = floats(72.85, 72.91)
    lit(mask) = .!ismissing.(Array(mask))

    @property max_examples=CHEAP function ring_lies_inside_its_disk(lat = lats, long = longs, r1 = floats(0.1, 2.0), r2 = floats(0.1, 2.0))
        r1, r2 = minmax(r1, r2)
        bounds, ring = annular_ring(img, r1, r2, lat, long, res)
        disk_bounds, disk = annular_ring(img, r2, lat, long, res)
        bounds == disk_bounds && all(x -> isequal(x, 1) || ismissing(x), ring) && all(lit(ring) .<= lit(disk))
    end

    @property max_examples=CHEAP function disk_is_ring_with_no_hole(lat = lats, long = longs, r = floats(0.1, 2.0))
        isequal(annular_ring(img, r, lat, long, res), annular_ring(img, 0, r, lat, long, res))
    end

    @property max_examples=CHEAP function centre_lit_only_without_hole(lat = lats, long = longs, r1 = floats(0.0, 1.0))
        bounds, mask = annular_ring(img, r1, 2.0, lat, long, res)
        cropped = img[bounds...]
        x = DimensionalData.dims2indices(dims(cropped, X), X(Near(long)))
        y = DimensionalData.dims2indices(dims(cropped, Y), Y(Near(lat)))
        ismissing(mask[x, y, 1]) == (r1 > 0)
    end

    # radius^2 = 0 -> Int(NaN)
    for r in (nextfloat(0.0), 1e-200, 1e-6)
        bounds, mask = annular_ring(img, r, 2.0, 19.07, 72.87, res)
        @test count(ismissing, mask) > count(ismissing, annular_ring(img, 2.0, 19.07, 72.87, res)[2])
    end
    @test_nowarn annular_ring(img, nextfloat(0.0), 19.07, 72.87, res)
end
