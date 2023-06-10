"""
There are extremely high values in the data due to fires, gas flare etc. You may find some values even greater than the aggregate radiance of large cities. Such pixels also have high standard deviation. These pixels may not be of importantance from the point of view of measureming prosperity. The ```outlier_variance``` function generates a mask of pixels with standard deviation less that the 99.9th percentile. Essentially, this function can be used to removed top 1 percent of pixels by standard deviation. A mask can be provided to the function, so that it calculates the percentile based on the lit pixel of the mask. For example, if the datacube is a box around India and the mask is the polygon mask of India, the outlier_variance function will calculate the 99th percentile of the standard deviation of the pixels inside India's boundary. 

```julia
outlier_variance(datacube, mask)
```
"""
function outlier_variance(datacube, mask=ones(Int8, (size(datacube)[1],size(datacube)[2])))
    function std_mask(std, threshold)
        if std < threshold
            return 1
        else 
            return missing
        end
    end
    stds = zeros(size(datacube)[1], size(datacube)[2])
    for i in 1:size(datacube)[1]
        for j in 1:size(datacube)[2]
            if ismissing(mask[i, j])
                continue
            end
            if count(i->(ismissing(i)),datacube[i, j, :])/length(datacube[i, j, :]) > 0.50  # Don't do anything if there are too many missings
                continue
            end
            stds[i, j] = std(detrend_ts(filter(x -> !ismissing(x), datacube[i, j, :])))
        end
    end
    threshold   = quantile(skipmissing(vec(stds .* mask)), 0.999)
    outlierMask = std_mask.(stds, threshold)
    outlierMask = outlierMask.*mask
    return outlierMask
end

"""
The time series of a pixel may show a few outliers, but as a whole the pixel may be of importantance in measuring economic activity. The outlier_hampel function uses replaces the outlier observations with interpolated values. This is done using the tsclean function the forecast package of R.

```julia
sample_timeseries = datacube[1, 2, :] # The time series of pixel [1, 2]
outlier_hampel(sample_timeseries)
```
"""
function outlier_hampel(timeseries, window_size = 5, n_sigmas = 3)
    timeseries = Array(timeseries)
    # Credit: https://gist.github.com/erykml/d15525855f2ef455bd7969240f6f4073#file-hampel_filter_forloop-py
    missings = findall(ismissing, timeseries)
    new_series = Array{Union{Float64, Missing}}(filter!(!ismissing, copy(timeseries))) 
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
