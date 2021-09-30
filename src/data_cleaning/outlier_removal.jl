"""
There are extremely high values in the data due to fires, gas flare etc. You may find some values even greater than the aggregate radiance of large cities. Such pixels also have high standard deviation. These pixels may not be of importantance from the point of view of measureming prosperity. The ```outlier_mask``` function generates a mask of pixels with standard deviation less that the 99.9th percentile. Essentially, this function can be used to removed top 1 percent of pixels by standard deviation. A mask can be provided to the function, so that it calculates the percentile based on the lit pixel of the mask. For example, if the datacube is a box around India and the mask is the polygon mask of India, the outlier_mask function will calculate the 99th percentile of the standard deviation of the pixels inside India's boundary. 

```julia
outlier_mask(datacube, mask)
```
"""
function outlier_mask(datacube, mask)
    stds = zeros(size(datacube)[1], size(datacube)[2])
    @showprogress for i in 1:size(datacube)[1]
        for j in 1:size(datacube)[2]
            if mask[i, j]==0
                continue
            end
            if counter_nan(datacube[i, j, :])/length(datacube[i, j, :]) > 0.50 # Don't do anything if there are too many NaNs
                continue
            end
            stds[i, j] = std(detrend_ts(filter(x -> !isnan(x), datacube[i, j, :])))
        end
    end
    function std_mask(std, threshold)
        if std < threshold
            return 1
        else 
            return 0
        end
    end
    threshold   = quantile(mask_vals(stds, mask), 0.999)
    outlierMask = std_mask.(stds, threshold)
    outlierMask = outlierMask.*mask
    outlierMask = convert(Array{Int8, 2}, outlierMask)
    return outlierMask
end

"""
The time series of a pixel may show a few outliers, but as a whole the pixel may be of importantance in measuring economic activity. The outlier_ts function uses replaces the outlier observations with interpolated values. This is done using the tsclean function the forecast package of R.

```julia
sample_timeseries = datacube[1, 2, :] # The time series of pixel [1, 2]
outlier_ts(sample_timeseries)
```
"""
function outlier_ts(timeseries)
    if counter_nan(timeseries)/length(timeseries)>0.50
        return timeseries
    end 
    R"""
    library(compiler)
    ROutlierRem <- function(x) {
        library(forecast)
        return<-tsclean(x, replace.missing=FALSE)
    }
    """
    array = copy(timeseries)
    return convert(Array{Float16}, rcall(:ROutlierRem, array))
end
