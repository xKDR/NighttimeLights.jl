"""
There are extremely high values in the nighttime lights data due to fires, gas flare etc. You may find some values even greater than the aggregate radiance of large cities. Such pixels also have high standard deviation. These pixels may not be of importantance from the point of view of measureming prosperity. The `outlier_variance` function generates a mask of pixels with standard deviation less that a user defined cutoff value, that defaults to the 99.9th percentile. Essentially, this function can be used to remove the pixels with the high standard deviation. A mask can be provided to the function, so that it calculates the percentile based on the lit pixel of the mask. For example, if the `radiance_datacube` is a box around Mumbai and the mask is the polygon mask of Mumbai, the `outlier_variance` function will calculate the 99.9th percentile (default cutoff value) of the standard deviation of the pixels inside Mumbai's boundary. 

```julia
outlier_variance(radiance_datacube, mask; cutoff = 0.999)
```

Limitations: the cutoff is a share of pixels, not a level of variability. The top `1 - cutoff` of pixels are always dropped, even when there is no fire or flare; since the standard deviation is not scaled by radiance, these are usually the brightest stable pixels, and in a small region one such pixel can be a noticeable share of total radiance. When more than `1 - cutoff` of the pixels are flares, the rest are kept.
"""
function outlier_variance(radiance_datacube, mask=ones(Int8, (size(radiance_datacube)[1],size(radiance_datacube)[2])); cutoff = 0.999)
    function std_mask(std, threshold)
        if std < threshold
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
            if count(i->(ismissing(i)),radiance_datacube[i, j, :])/length(radiance_datacube[i, j, :]) > 0.90  # Don't do anything if there are too many missings
                continue
            end
            stds[i, j] = std(detrend_ts(filter(x -> !ismissing(x), radiance_datacube[i, j, :])))
        end
    end
    threshold   = quantile(skipmissing(vec(stds .* mask)), cutoff)
    outlierMask = std_mask.(stds, threshold)
    outlierMask = outlierMask.*mask
    return outlierMask
end

"""
The time series of a pixel may show a few outliers, but as a whole the pixel may be of importantance in measuring economic activity. The `outlier_hampel` function applies a Hampel filter: an observation that is more than `n_sigmas` scaled median absolute deviations (default 3) from the median of the window around it (default `window_size = 5`) is replaced with `missing`. Missing values in the input are ignored by the filter and kept in place. The `missing` values can be filled afterwards with `na_interp_linear`.

```julia
outlier_hampel(radiance_pixel_ts)
```

Limitations: only observations with a full window on both sides are checked, so the first `window_size - 1` and the last `window_size` non-missing observations are never flagged. At the ends of a series a single outlier cannot be told apart from the start of a real change in level, so spikes there are kept rather than risk removing real changes in the most recent months.
"""
function outlier_hampel(radiance_pixel_ts, window_size = 5, n_sigmas = 3)
    radiance_pixel_ts = Array(radiance_pixel_ts)
    # Credit: https://gist.github.com/erykml/d15525855f2ef455bd7969240f6f4073#file-hampel_filter_forloop-py
    missings = findall(ismissing, radiance_pixel_ts)
    new_series = Array{Union{Float64, Missing}}(filter!(!ismissing, copy(radiance_pixel_ts))) 
    n = length(new_series)
    k = 1.4826 # scale factor for Gaussian distribution
    indices = []
    # ends skipped on purpose: see Limitations in the docstring
    for i in (window_size):(n - window_size)
        x0 = median(new_series[(i - window_size+1):(i + window_size)]) # Use this for the time series outlier package
        # x0 = missing
        S0 = k * median(abs.(new_series[(i - window_size +1):(i + window_size)] .- x0))
        if (abs(new_series[i] - x0) > n_sigmas * S0)
            # new_series[i] = missing # Can use x0   
            push!(indices, i)
        end
    end
    new_series[indices] .= missing
    for i in missings # putting back the missing values
        new_series = insert!(new_series, i, missing)
    end
    return new_series
end
