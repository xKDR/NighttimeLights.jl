"""
There are extremely high values in the nighttime lights data due to fires, gas flare etc. You may find some values even greater than the aggregate radiance of large cities. Such pixels also have high standard deviation. These pixels may not be of importantance from the point of view of measureming prosperity. The `outlier_variance` function generates a mask of pixels with standard deviation less that a user defined cutoff value, that defaults to the 99.9th percentile. Essentially, this function can be used to remove the pixels with the high standard deviation. A mask can be provided to the function, so that it calculates the percentile based on the lit pixel of the mask. For example, if the `radiance_datacube` is a box around Mumbai and the mask is the polygon mask of Mumbai, the `outlier_variance` function will calculate the 99th percentile (default cutoff value) of the standard deviation of the pixels inside Mumbai's boundary. 

```julia
outlier_variance(radiance_datacube, mask; cutoff = 0.999)
```
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
The time series of a pixel may show a few outliers, but as a whole the pixel may be of importantance in measuring economic activity. The outlier_hampel function uses replaces the outlier observations with interpolated values. This is done using the tsclean function the forecast package of R.

```julia
outlier_hampel(radiance_pixel_ts)
```
"""
function outlier_hampel(radiance_pixel_ts, window_size = 5, n_sigmas = 3)
    radiance_pixel_ts = Array(radiance_pixel_ts)
    # Credit: https://gist.github.com/erykml/d15525855f2ef455bd7969240f6f4073#file-hampel_filter_forloop-py
    missings = findall(ismissing, radiance_pixel_ts)
    new_series = Array{Union{Float64, Missing}}(filter!(!ismissing, copy(radiance_pixel_ts))) 
    n = length(new_series)
    k = 1.4826 # scale factor for Gaussian distribution
    indices = [] 
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
