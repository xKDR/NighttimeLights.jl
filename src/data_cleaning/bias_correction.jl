"""
Cloudy months tends to have lower radiance due to attenuation. The bias_PSTT2021 function uses the number of cloud-free observations to adjust the radiance accordingly.
```julia
bias_PSTT2021(radiance_pixel_ts, ncfobs_pixel_ts)
```
"""
function bias_PSTT2021_pixel(radiance_pixel_ts, ncfobs_pixel_ts, span=0.75)
    miss_idx = findall(ismissing, radiance_pixel_ts)
    y = collect(skipmissing(radiance_pixel_ts))
    x = Float64.(collect(skipmissing(_mask_at(ncfobs_pixel_ts, miss_idx))))
    y_ = Array{Float64}(detrend_ts(y))
    sort_idx = sortperm(x)
    m = similar(x)
    m[sort_idx] = lowess(x[sort_idx], y_[sort_idx], span)
    topval = maximum(m)
    fixed1 = y_ .- m .+ topval
    fixed2 = fixed1 .+ y .- y_ # adding the time trend
    maxy = maximum(y)
    for i in eachindex(fixed2)
        if fixed2[i] > maxy
            fixed2[i] = y[i]
        end
    end
    return _reinsert_missings(fixed2, miss_idx, length(radiance_pixel_ts))
end

"""
Bias-correct a single pixel given pre-filtered (non-missing) radiance and ncfobs arrays.
Avoids the duplicate filtering done by the datacube wrapper.
"""
function _bias_PSTT2021_pixel_prefiltered(y, x, miss_idx, total_len, span=0.75)
    x = Float64.(x)
    y_ = Array{Float64}(detrend_ts(y))
    sort_idx = sortperm(x)
    m = similar(x)
    m[sort_idx] = lowess(x[sort_idx], y_[sort_idx], span)
    topval = maximum(m)
    fixed1 = y_ .- m .+ topval
    fixed2 = fixed1 .+ y .- y_
    maxy = maximum(y)
    for i in eachindex(fixed2)
        if fixed2[i] > maxy
            fixed2[i] = y[i]
        end
    end
    return _reinsert_missings(fixed2, miss_idx, total_len)
end

# Mask values at given indices as missing, then return the array
function _mask_at(arr, miss_idx)
    x = Array{Union{Float64, Missing}}(copy(arr))
    x[miss_idx] .= missing
    return x
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
            miss_idx = findall(ismissing, rad_ts)
            radiance_arr = collect(skipmissing(rad_ts))
            ncfobs_arr = collect(skipmissing(_mask_at(ncfobs_datacube[i, j, :], miss_idx)))
            if rank_correlation_test(radiance_arr, ncfobs_arr) < 0.05
                radiance_datacube[i, j, :] = _bias_PSTT2021_pixel_prefiltered(radiance_arr, ncfobs_arr, miss_idx, length(rad_ts))
            end
        end
    end
    return radiance_datacube
end
