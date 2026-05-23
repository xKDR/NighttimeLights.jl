"""
Cloudy months tends to have lower radiance due to attenuation. The bias_PSTT2021 function uses the number of cloud-free observations to adjust the radiance accordingly. 
```julia
bias_PSTT2021(radiance_pixel_ts, ncfobs_pixel_ts)
```
"""
function bias_PSTT2021_pixel(radiance_pixel_ts, ncfobs_pixel_ts, smoothing_parameter=10.0)
    missings = findall(ismissing, radiance_pixel_ts)
    non_missing_mask = .!ismissing.(radiance_pixel_ts)
    y = Float64.(collect(skipmissing(radiance_pixel_ts)))
    x = Float64.(Array(ncfobs_pixel_ts)[non_missing_mask[1:length(ncfobs_pixel_ts)]])
    y_ = Float64.(detrend_ts(y))
    m = predict(fit(SmoothingSpline, x, y_, smoothing_parameter), x)
    topval = maximum(m)
    fixed1 = y_ .- m .+ topval
    fixed2 = fixed1 .+ y .- y_ # adding the time trend
    maxy = maximum(y)
    for i in 1:length(y)
        if fixed2[i] > maxy
            fixed2[i] = y[i]
        end
    end
    result = Vector{Union{Float64, Missing}}(undef, length(radiance_pixel_ts))
    j = 1
    for i in 1:length(radiance_pixel_ts)
        if ismissing(radiance_pixel_ts[i])
            result[i] = missing
        else
            result[i] = fixed2[j]
            j += 1
        end
    end
    return result
end

"""
The bias correction function can use the datacubes of radiance and the number of cloud-free observations to correct for attenuation in radiance due to low number of cloud-free observations. 
```julia
bias_PSTT2021(radiance_datacube, ncfobs_datacube)
```
"""
function bias_PSTT2021(radiance_datacube, ncfobs_datacube, mask=ones(Int8, (size(radiance_datacube)[1],size(radiance_datacube)[2])))
    for i in 1:size(radiance_datacube)[1]
        for j in 1:size(radiance_datacube)[2]
            if ismissing(mask[i, j])
                continue
            end
            rad_ts = radiance_datacube[i, j, :]
            if count(ismissing, rad_ts) / length(rad_ts) > 0.90
                continue
            end
            non_missing = .!ismissing.(rad_ts)
            radiance_arr = Float64.(collect(skipmissing(rad_ts)))
            ncfobs_arr = Array(ncfobs_datacube[i, j, :])[non_missing]
            if rank_correlation_test(radiance_arr, ncfobs_arr) < 0.05
                radiance_datacube[i, j, :] = bias_PSTT2021_pixel(copy(rad_ts), copy(ncfobs_datacube[i, j, :]))
            end
        end
    end
    return radiance_datacube
end
