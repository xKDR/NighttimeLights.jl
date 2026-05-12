# Earth geometry lookup tables (latitude → pixel size in km)
const _RING_LAT = [-90.0, -89, -86, -82, -78, -74, -70, -60, -50, -40, -30, -20, -10, 0, 10, 20, 30, 40, 50, 60, 70, 74, 78, 82, 86, 89, 90]
const _RING_EW  = [0, 16.0, 64, 133, 193, 256, 318, 465, 598, 712, 804, 872, 914, 928, 914, 872, 804, 712, 598, 465, 318, 256, 193, 133, 64, 16, 0] / 1000
const _RING_NS  = [931, 931.0, 931, 931, 930, 930, 930, 929, 927, 925, 924, 923, 922, 921, 922, 923, 924, 925, 927, 929, 930, 930, 930, 931, 931, 931, 931] / 1000

function _earth_pixel_size(lat, res)
    ew = _RING_EW / (30 / res)
    ns = _RING_NS / (30 / res)
    model_ew = CubicSpline(_RING_LAT, ew)
    model_ns = CubicSpline(_RING_LAT, ns)
    return model_ew[lat], model_ns[lat]
end

"""
```julia
using Plots
res = 15
R1 = 2
R2 = 5
lat = 19.07
long = 72.87
bounds, mask = annular_ring(radiance_image, R1, R2, lat, long, res)
plot(Rasters.mask(radiance_image[bounds...], with = mask))
```
"""
function annular_ring(radiance_image, R1, R2, lat, long, res)
    if R2 < R1
        @error "R1 must be less than R2"
    end

    Δx, Δy = _earth_pixel_size(lat, res)

    a1 = R1 / Δx
    b1 = R1 / Δy
    a2 = R2 / Δx
    b2 = R2 / Δy

    xₒ = DimensionalData.dims2indices(dims(radiance_image)[1], X(Near(long)))
    yₒ = DimensionalData.dims2indices(dims(radiance_image)[2], Y(Near(lat)))

    ymin = yₒ + Int(round(b2)) + 5
    ymax = yₒ - Int(round(b2)) - 5
    xmin = xₒ - Int(round(a2)) - 5
    xmax = xₒ + Int(round(a2)) + 5

    longmin, latmin = map(getindex, dims(radiance_image), [xmin, ymin])
    longmax, latmax = map(getindex, dims(radiance_image), [xmax, ymax])

    bounds = X(Rasters.Between(longmin, longmax)), Y(Rasters.Between(latmin, latmax))
    img2 = radiance_image[bounds...]

    xₒ = DimensionalData.dims2indices(dims(img2)[1], X(Near(long)))
    yₒ = DimensionalData.dims2indices(dims(img2)[2], Y(Near(lat)))

    width_at_1(y) = Int(round(a1 * sqrt(abs((1 - (y-yₒ)^2 / b1 ^2)))))
    width_at_2(y) = Int(round(a2 * sqrt(abs((1 - (y-yₒ)^2 / b2 ^2)))))
    mask2 = Raster(Array{Union{Missing, Int64}}(missing, size(img2)), dims(img2))

    ymin = yₒ + Int(round(b2))
    ymax = yₒ - Int(round(b2))

    for i in ymax:ymin
        for j in (xₒ-width_at_2(i)):(xₒ+ width_at_2(i))
            mask2[j, i, 1] = 1
        end
    end

    ymin = yₒ + Int(round(b1))
    ymax = yₒ - Int(round(b1))

    mask1 = Raster(Array{Union{Missing, Int64}}(missing, size(img2)), dims(img2))
    mask1 .= 1

    for i in ymax:ymin
        for j in (xₒ-width_at_1(i)):(xₒ+ width_at_1(i))
            mask1[j, i, 1] = missing
        end
    end
    mask = mask1 .* mask2
    return bounds, mask
end

"""
```julia
using Plots
res = 15
R = 2
lat = 19.07
long = 72.87
bounds, mask = annular_ring(radiance_image, R, lat, long, res)
plot(Rasters.mask(radiance_image[bounds...], with = mask))
```
"""
function annular_ring(radiance_image, R, lat, long, res)
    Δx, Δy = _earth_pixel_size(lat, res)

    a = R / Δx
    b = R / Δy

    xₒ = DimensionalData.dims2indices(dims(radiance_image)[1], X(Near(long)))
    yₒ = DimensionalData.dims2indices(dims(radiance_image)[2], Y(Near(lat)))

    ymin = yₒ + Int(round(b)) + 5
    ymax = yₒ - Int(round(b)) - 5
    xmin = xₒ - Int(round(a)) - 5
    xmax = xₒ + Int(round(a)) + 5

    longmin, latmin = map(getindex, dims(radiance_image), [xmin, ymin])
    longmax, latmax = map(getindex, dims(radiance_image), [xmax, ymax])

    bounds = X(Rasters.Between(longmin, longmax)), Y(Rasters.Between(latmin, latmax))
    img2 = radiance_image[bounds...]

    xₒ = DimensionalData.dims2indices(dims(img2)[1], X(Near(long)))
    yₒ = DimensionalData.dims2indices(dims(img2)[2], Y(Near(lat)))

    width_at_2(y) = Int(round(a * sqrt(abs((1 - (y-yₒ)^2 / b ^2)))))
    mask = Raster(Array{Union{Missing, Int64}}(missing, size(img2)), dims(img2))

    ymin = yₒ + Int(round(b))
    ymax = yₒ - Int(round(b))

    for i in ymax:ymin
        for j in (xₒ-width_at_2(i)):(xₒ+ width_at_2(i))
            mask[j, i, 1] = 1
        end
    end
    return bounds, mask
end
