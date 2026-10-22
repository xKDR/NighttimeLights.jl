@testset "na_recode" begin
    expected(rad, ncf) = ncf == 0 ? missing : rad

    @property max_examples=CHEAP function marks_cloudy_months_in_cube(c = cubes(maybe_missing(radiance()), ncfobs()))
        rad, ncf = c
        isequal(Array(na_recode(as_raster(rad), as_raster(ncf))), expected.(rad, ncf))
    end

    @property max_examples=CHEAP function accepts_cube_without_missing_eltype(c = cubes(radiance(), ncfobs()))
        rad, ncf = c
        isequal(Array(na_recode(as_raster(rad), as_raster(ncf))), expected.(rad, ncf))
    end

    @property max_examples=CHEAP function marks_cloudy_months_in_image(c = cubes(radiance(), ncfobs()))
        rad, ncf = c
        img, ncf_img = as_missable(rad[:, :, 1]), ncf[:, :, 1]
        isequal(NighttimeLights.na_recode_img(copy(img), ncf_img), expected.(img, ncf_img))
    end

    @property max_examples=CHEAP function custom_replacement(c = cubes(radiance(), ncfobs()))
        rad, ncf = c
        out = na_recode(as_raster(rad), as_raster(ncf); replacement = -1.0)
        isequal(Array(out), ifelse.(ncf .== 0, -1.0, rad))
    end
end
