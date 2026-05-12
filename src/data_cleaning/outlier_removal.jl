"""
There are extremely high values in the nighttime lights data due to fires, gas flare etc. You may find some values even greater than the aggregate radiance of large cities. Such pixels also have high standard deviation. These pixels may not be of importantance from the point of view of measureming prosperity. The `outlier_variance` function generates a mask of pixels with standard deviation less that a user defined cutoff value, that defaults to the 99.9th percentile. Essentially, this function can be used to remove the pixels with the high standard deviation. A mask can be provided to the function, so that it calculates the percentile based on the lit pixel of the mask. For example, if the `radiance_datacube` is a box around Mumbai and the mask is the polygon mask of Mumbai, the `outlier_variance` function will calculate the 99th percentile (default cutoff value) of the standard deviation of the pixels inside Mumbai's boundary.

```julia
outlier_variance(radiance_datacube, mask; cutoff = 0.999)
```
"""
function outlier_variance(radiance_datacube, mask=ones(Int8, (size(radiance_datacube)[1],size(radiance_datacube)[2])); cutoff = 0.999)
    function std_mask(s, threshold)
        if s < threshold
            return 1
        else
            return missing
        end
    end
    stds = zeros(size(radiance_datacube)[1], size(radiance_datacube)[2])
    for i in 1:size(radiance_datacube)[1]
        for j in 1:size(radiance_datacube)[2]
            if ismissing(mask[i, j])
                continue
            end
            pixel_ts = radiance_datacube[i, j, :]
            if count(ismissing, pixel_ts) / length(pixel_ts) > 0.90
                continue
            end
            stds[i, j] = std(detrend_ts(collect(skipmissing(pixel_ts))))
        end
    end
    threshold   = quantile(skipmissing(vec(stds .* mask)), cutoff)
    outlierMask = std_mask.(stds, threshold)
    outlierMask = outlierMask.*mask
    return outlierMask
end

"""
The time series of a pixel may show a few outliers, but as a whole the pixel may be of importantance in measuring economic activity. The outlier_hampel function uses replaces the outlier observations with interpolated values. This is done using the tsclean function the forecast package of R.

```julia
outlier_hampel(radiance_pixel_ts)
```
"""
function outlier_hampel(radiance_pixel_ts, window_size = 5, n_sigmas = 3)
    radiance_pixel_ts = Array(radiance_pixel_ts)
    miss_idx = findall(ismissing, radiance_pixel_ts)
    new_series = Array{Union{Float64, Missing}}(collect(skipmissing(radiance_pixel_ts)))
    n = length(new_series)
    k = 1.4826 # scale factor for Gaussian distribution
    indices = Int[]
    for i in window_size:(n - window_size)
        x0 = median(new_series[(i - window_size+1):(i + window_size)])
        S0 = k * median(abs.(new_series[(i - window_size +1):(i + window_size)] .- x0))
        if (abs(new_series[i] - x0) > n_sigmas * S0)
            push!(indices, i)
        end
    end
    new_series[indices] .= missing
    return _reinsert_missings(new_series, miss_idx, length(radiance_pixel_ts))
end

# Pre-allocate result with missings at correct positions instead of insert! in a loop
function _reinsert_missings(values, miss_idx, total_len)
    result = Vector{Union{Float64, Missing}}(missing, total_len)
    miss_set = Set(miss_idx)
    vi = 1
    for i in 1:total_len
        if i in miss_set
            continue
        end
        result[i] = values[vi]
        vi += 1
    end
    return result
end
