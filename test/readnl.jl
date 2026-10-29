using GeoInterface

# following VIIRS monthly naming; first date = month.
viirs_name(d::Date) = "SVDNB_npp_$(Dates.format(d, "yyyymmdd"))-$(Dates.format(lastdayofmonth(d), "yyyymmdd"))_75N060E_vcmslcfg_v10_c0.avg_rade9h.tif"

@testset "sort_files_by_date" begin
    month(k) = Date(2012, 4) + Month(k)

    @property max_examples=CHEAP function sorts_and_filters_by_date(ks = Data.Vectors(Data.Integers(0, 150); max_size = 20),
                                                                 a = Data.Integers(0, 150), b = Data.Integers(0, 150))
        mktempdir() do dir
            for k in ks
                touch(joinpath(dir, viirs_name(month(k))))
            end
            touch(joinpath(dir, "README.txt"))
            lo, hi = month.(minmax(a, b))
            files, dates = NighttimeLights.sort_files_by_date(dir, lo, hi)
            expected = sort(unique(filter(d -> lo <= d <= hi, month.(ks))))
            dates == DateTime.(expected) && files == viirs_name.(expected)
        end
    end
end

@testset "readers on synthetic tifs" begin
    months = Date(2015, 1):Month(1):Date(2015, 4)
    lon, lat = X(72.05:0.1:72.95), Y(19.95:-0.1:19.05)
    rad_dir, cf_dir = mktempdir() * "/", mktempdir() * "/"
    for (k, d) in enumerate(months)
        write(rad_dir * viirs_name(d), Raster(fill(10.0k, 10, 10), (lon, lat); crs = EPSG(4326)))
        write(cf_dir * viirs_name(d), Raster(fill(Int16(k), 10, 10), (lon, lat); crs = EPSG(4326)))
    end
    paths = (; rad_path = rad_dir, cf_path = cf_dir)
    inside(r, xs, ys) = all(x -> xs[1] <= x <= xs[2], dims(r, X)) && all(y -> ys[1] <= y <= ys[2], dims(r, Y))

    rad, cf = readnl_date(Date(2015, 2); paths...)
    @test all(==(20.0), rad) && all(==(2), cf)
    rad, cf = readnl_date(Date(2015, 2); paths..., resample_factor = 2)
    @test size(rad) == size(cf) == (5, 5)

    rad, cf = readnl_rectangle(X(Rasters.Between(72.2, 72.5)), Y(Rasters.Between(19.3, 19.6)), Date(2015, 2), Date(2015, 3); paths...)
    @test collect(dims(rad, Ti)) == collect(dims(cf, Ti)) == DateTime.([Date(2015, 2), Date(2015, 3)])
    @test all(==(20.0), rad[Ti = 1]) && all(==(30.0), rad[Ti = 2]) && all(==(3), cf[Ti = 2])
    @test inside(rad, (72.2, 72.5), (19.3, 19.6)) && size(rad, 1) > 0 && size(rad, 2) > 0

    small, _ = readnl_rectangle(X(Rasters.Between(72.2, 72.5)), Y(Rasters.Between(19.3, 19.6)), Date(2015, 2), Date(2015, 3); paths..., resample_factor = 2)
    @test size(small, Ti) == 2 && all(size(small)[1:2] .< size(rad)[1:2]) && all(==(30.0), small[Ti = 2])

    box = GeoInterface.Wrappers.Polygon([[(72.2, 19.3), (72.5, 19.3), (72.5, 19.6), (72.2, 19.6), (72.2, 19.3)]])
    rad, cf = readnl_geom(box, Date(2015, 1), Date(2015, 4); paths...)
    @test size(rad, Ti) == 4 && all(==(40.0), rad[Ti = 4])
    @test inside(rad, (72.15, 72.55), (19.25, 19.65)) && size(rad)[1:2] == size(cf)[1:2]
    small, small_cf = readnl_geom(box, Date(2015, 1), Date(2015, 4); paths..., resample_factor = 2)
    @test size(small, Ti) == 4 && all(size(small)[1:2] .< size(rad)[1:2]) && size(small) == size(small_cf)
    @test all(==(40.0), small[Ti = 4])

    noise_path = joinpath(mktempdir(), "lit_mask.tif")
    lit = [isodd(i + j) ? 1 : 0 for i in 1:10, j in 1:10]
    write(noise_path, Raster(Int8.(lit), (lon, lat); crs = EPSG(4326)))
    expected(m) = all(ij -> isequal(m[ij], lit[ij] == 1 ? 1 : missing), CartesianIndices(m))
    @test expected(read_noise_mask(; path = noise_path))
    cropped = read_noise_mask(box; path = noise_path)
    @test 0 < length(cropped) < 100 && all(x -> isequal(x, 1) || ismissing(x), cropped)
    cropped = read_noise_mask(X(Rasters.Between(72.2, 72.5)), Y(Rasters.Between(19.3, 19.6)); path = noise_path)
    @test inside(cropped, (72.2, 72.5), (19.3, 19.6)) && all(x -> isequal(x, 1) || ismissing(x), cropped)
    @test size(read_noise_mask(; path = noise_path, resample_factor = 2)) == (5, 5)
    @test length(read_noise_mask(box; path = noise_path, resample_factor = 2)) < length(read_noise_mask(box; path = noise_path))
    @test length(read_noise_mask(X(Rasters.Between(72.2, 72.5)), Y(Rasters.Between(19.3, 19.6)); path = noise_path, resample_factor = 2)) < length(cropped)
end
