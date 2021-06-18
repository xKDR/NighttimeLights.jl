function outlier_mask(datacube,mask)
    """
    Generates a mask of pixels with standard deviation less that the 99.9th percentile. 
    """
    stds = zeros(size(datacube)[1], size(datacube)[2])
    @showprogress for i in 1:size(datacube)[1]
        for j in 1:size(datacube)[2]
            if mask[i,j]==0
                continue
            end
            if counter_nan(datacube[i,j,:])>50
                continue
            end
            stds[i,j] = std(detrend_ts(filter(x -> !isnan(x),datacube[i,j,:])))
        end
    end
    function std_mask(std,threshold)
        if std<threshold
            return 1
        else 
            return 0
        end
    end
    threshold = quantile(mask_vals(stds,mask),0.999)
    outlierMask= std_mask.(stds,threshold)
    outlierMask = outlierMask.*mask
    outlierMask = convert(Array{Int8,2},outlierMask)
    return outlierMask
end

function outlier_ts(arr)
    R"""
    library(compiler)
    ROutlierRem <- function(x) {
        library(forecast)
        return<-tsclean(x, replace.missing=FALSE)
    }
    """
    array = copy(arr)
    """
    Applies tsclean outlier removal from Rob Hyndman's package forecast in R
    """
    return convert(Array{Float16},rcall(:ROutlierRem,array))
end
