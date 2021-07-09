"""
Clouds months tends to have lower radiance due to attenuation. The bias_correction function uses the number of cloud-free observations to adjust the radiance accordingly. 
```julia
bias_correction(radiance, clouds)
```
"""
function bias_correction(radiance::Array{T, 1}, clouds) where T <: Real
R"""
library(zoo)
library(dplyr)
bias_correction_R <- function(radiance, clouds)
{
    cf                  <- clouds/max(clouds)
    date                <- seq(as.yearmon("2012-04"), by = 1/12, length.out = length(radiance))
    # test if any sequence of numbers gives the same result. Don't have to waste time on time. 
    time                <- date - as.yearmon("2012-04")
    m0                  <- lm(radiance ~ time, na.action = na.exclude)
    ly0                 <- residuals(m0)
    cor_test            <- cor.test(clouds, ly0, alternative = "greater", method = "spearman", exact = FALSE, na.action = na.omit)
    if (cor_test$p.value > 0.05){
        return          <- radiance
    } 
    ly1                 <- log(radiance)            
    m.timetrend         <- lm(ly1 ~ time, na.action = na.exclude)
    ly2                 <- residuals(m.timetrend)           # ly2 is the residuals after removing the time trend
    m.loess             <- loess(ly2 ~ cf, na.action = "na.exclude")
    topval              <- predict(m.loess, newdata = data.frame(cf=1, ly2=NA))
    tocorrect.cf         <- cf < 1
    tocorrect.ly2   <- ly2 < 0
    tocorrect           <- as.logical(tocorrect.cf * tocorrect.ly2)
    tocorrect[is.na(tocorrect)] <- FALSE
    corrected           <- ly2 + topval - predict(m.loess)
    fixed.1             <- ly2
    fixed.1[tocorrect]  <- corrected[tocorrect]
    fixed.2             <- fixed.1 + (coef(m.timetrend)[2] * time) + coef(m.timetrend)[1]
    return              <- exp(fixed.2)
}"""
return convert(Array{T, 1}, rcall(:bias_correction_R, radiance, clouds))
end

"""
The bias correction function can use the datacubes of radiance and the number of cloud-free observations to correct for attenuation in radiance due to low number of cloud-free observations. 
```julia
bias_correction(radiance, clouds)
```
"""
function bias_correction(radiance_datacube::Array{T, 3}, clouds_datacube, mask=ones(Int8, (size(radiance_datacube)[1],size(radiance_datacube)[2]))) where T <: Real
    rad_corrected_datacube = copy(radiance_datacube)
    @showprogress for i in 1:size(radiance_datacube)[1]
        for j in 1:size(radiance_datacube)[2]
            if counter_nan(radiance_datacube[i, j, :]) > 50 
                continue
            end
            if mask[i, j]==0
                continue
            end
            radiance_arr = radiance_datacube[i, j, :]
            clouds_arr = clouds_datacube[i , j, :]
            rad_corrected_datacube[i, j, :]= bias_correction(radiance_arr, clouds_arr)
        end
    end
    return rad_corrected_datacube
end
