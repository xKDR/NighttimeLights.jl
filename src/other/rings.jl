"""
```julia
using Plots
load_example()
img = view(radiance_datacube, Ti(At(201204)))
res = 15
R1 = 2
R2 = 5
lat = 19.07
long = 72.87
bounds, mask = annular_ring(img, R1, R2, lat, long, res) 
plot(Rasters.mask(img[bounds...], with = mask))
```
"""
function annular_ring(img, R1, R2, lat, long, res)
    if R2 < R1 
        @error "R1 must be less than R2"
    end
    LAT =[-90.0, -89, -86, -82, -78, -74, -70, -60, -50, -40, -30, -20, -10, 0, 10, 20, 30, 40, 50, 60, 70, 74, 78, 82, 86, 89, 90]
    EW  =[0, 16.0, 64, 133, 193, 256, 318, 465, 598, 712, 804, 872, 914, 928, 914, 872, 804, 712, 598, 465, 318, 256, 193, 133, 64, 16, 0]/1000
    NS  =[931, 931.0, 931, 931, 930, 930, 930, 929, 927, 925, 924, 923, 922, 921, 922, 923, 924, 925, 927, 929, 930, 930, 930, 931, 931,931, 931]/1000 # We divide by thousand to convert into kilometer from meter
    EW  = EW / (30 / res) # The values are for 30", our geometry is 15"
    NS  = NS / (30 / res) 
    MODEL_EW = CubicSpline(LAT, EW) 
    MODEL_NS = CubicSpline(LAT, NS) 

    Δx = MODEL_EW[lat]
    Δy = MODEL_NS[lat]

    a1 = R1 / Δx # Δx is assumed to be constant over small distances
    b1 = R1 / Δy # Δy is assumed to be constant over small distances

    a2 = R2 / Δx # Δx is assumed to be constant over small distances
    b2 = R2 / Δy # Δy is assumed to be constant over small distances

    xₒ = DimensionalData.dims2indices(dims(img)[1], X(Near(long)))
    yₒ = DimensionalData.dims2indices(dims(img)[2], Y(Near(lat)))

    ymin = yₒ + Int(round(b2)) + 5
    ymax = yₒ - Int(round(b2)) - 5
    xmin = xₒ - Int(round(a2)) - 5
    xmax = xₒ + Int(round(a2)) + 5

    longmin, latmin = map(getindex, dims(img), [xmin, ymin])
    longmax, latmax = map(getindex, dims(img), [xmax, ymax])

    bounds = X(Rasters.Between(longmin, longmax)), Y(Rasters.Between(latmin, latmax))
    img2 = img[bounds...]

    xₒ = DimensionalData.dims2indices(dims(img2)[1], X(Near(long)))
    yₒ = DimensionalData.dims2indices(dims(img2)[2], Y(Near(lat)))

    width_at_1(y) = Int(round(a1 * sqrt(abs((1 - (y-yₒ)^2 / b1 ^2))))) # equation of inner ellipse. 
    width_at_2(y) = Int(round(a2 * sqrt(abs((1 - (y-yₒ)^2 / b2 ^2))))) # equation of outer ellipse. 
    mask2 = Raster(missings(Int64, size(img2)), dims(img2))

    ymin = yₒ + Int(round(b2)) 
    ymax = yₒ - Int(round(b2))

    for i in ymax:ymin
        for j in (xₒ-width_at_2(i)):(xₒ+ width_at_2(i))
            mask2[j, i, 1] = 1
        end
    end

    ymin = yₒ + Int(round(b1)) 
    ymax = yₒ - Int(round(b1))

    mask1 = Raster(missings(Int64, size(img2)), dims(img2))
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
load_example()
img = view(radiance_datacube, Ti(At(Date("2012-06"))))
res = 15
R = 2
lat = 19.07
long = 72.87
bounds, mask = annular_ring(img, R, lat, long, res) 
plot(Rasters.mask(img[bounds...], with = mask))
```
"""
function annular_ring(img, R, lat, long, res)

    LAT =[-90.0, -89, -86, -82, -78, -74, -70, -60, -50, -40, -30, -20, -10, 0, 10, 20, 30, 40, 50, 60, 70, 74, 78, 82, 86, 89, 90]
    EW  =[0, 16.0, 64, 133, 193, 256, 318, 465, 598, 712, 804, 872, 914, 928, 914, 872, 804, 712, 598, 465, 318, 256, 193, 133, 64, 16, 0]/1000
    NS  =[931, 931.0, 931, 931, 930, 930, 930, 929, 927, 925, 924, 923, 922, 921, 922, 923, 924, 925, 927, 929, 930, 930, 930, 931, 931,931, 931]/1000 # We divide by thousand to convert into kilometer from meter
    EW  = EW / (30 / res) # The values are for 30", our geometry is 15"
    NS  = NS / (30 / res) 
    MODEL_EW = CubicSpline(LAT, EW) 
    MODEL_NS = CubicSpline(LAT, NS) 

    Δx = MODEL_EW[lat]
    Δy = MODEL_NS[lat]

    a = R / Δx # Δx is assumed to be constant over small distances
    b = R / Δy # Δy is assumed to be constant over small distances

    xₒ = DimensionalData.dims2indices(dims(img)[1], X(Near(long)))
    yₒ = DimensionalData.dims2indices(dims(img)[2], Y(Near(lat)))

    ymin = yₒ + Int(round(b)) + 5
    ymax = yₒ - Int(round(b)) - 5
    xmin = xₒ - Int(round(a)) - 5
    xmax = xₒ + Int(round(a)) + 5

    longmin, latmin = map(getindex, dims(img), [xmin, ymin])
    longmax, latmax = map(getindex, dims(img), [xmax, ymax])

    bounds = X(Rasters.Between(longmin, longmax)), Y(Rasters.Between(latmin, latmax))
    img2 = img[bounds...]

    xₒ = DimensionalData.dims2indices(dims(img2)[1], X(Near(long)))
    yₒ = DimensionalData.dims2indices(dims(img2)[2], Y(Near(lat)))

    width_at_2(y) = Int(round(a * sqrt(abs((1 - (y-yₒ)^2 / b ^2))))) # equation of outer ellipse. 
    mask = Raster(missings(Int64, size(img2)), dims(img2))

    ymin = yₒ + Int(round(b)) 
    ymax = yₒ - Int(round(b))

    for i in ymax:ymin
        for j in (xₒ-width_at_2(i)):(xₒ+ width_at_2(i))
            mask[j, i, 1] = 1
        end
    end
    return bounds, mask
end

# plot(Rasters.mask(img2, with = (mask1 .* mask)))
