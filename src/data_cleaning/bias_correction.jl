"""
Clouds months tends to have lower radiance due to attenuation. The bias_correction function uses the number of cloud-free observations to adjust the radiance accordingly. 
```julia
bias_correction(radiance, clouds)
```
"""
function bias_correction(radiance::Array{T, 1}, clouds, smoothing_parameter=10.0) where T <: Real
    nans = findall(isnan, radiance)
    y = filter!(!isnan, copy(radiance))
    x = convert(Array{Float64}, copy(clouds))
    x[nans] .= NaN
    x = filter!(!isnan, x)
    y_ = detrend_ts(y)
    m = predict(fit(SmoothingSpline, x, y_, smoothing_parameter), x)
    topval = maximum(m)
    fixed1 = y_ -m .+ topval
    fixed2 = fixed1 + y - y_ # adding the time trend
    for i in 1:length(y)
        if fixed2[i] > maximum(y)
            fixed2[i] = y[i]
        end
    end
    for i in nans #putting back the NAs
        fixed2 = insert!(fixed2, i, NaN)
    end
    return fixed2
end
# function bias_correction(radiance::Array{T, 1}, clouds) where T <: Real
#     R"""
#     bias_correction_R <- function(radiance, clouds)
#     {
#     cf                  <- clouds/max(clouds)
#     ly1                 <- radiance            
#     time                <- seq(1, length.out = length(radiance))
#     m.timetrend         <- lm(ly1 ~ time, na.action = na.exclude)
#     ly2                 <- residuals(m.timetrend)           # ly2 is the residuals after removing the time trend
#     m                   <- loess(ly2 ~ cf, na.action = "na.exclude")
#     topval              <- max(na.omit(predict(m)))#predict(m.loess, newdata=data.frame(cf=cutoff, ly2=NA))
#     corrected           <- ly2 + topval - predict(m)
#     fixed.1             <- ly2
#     fixed.1             <- corrected 
#     fixed.2             <- fixed.1 + (coef(m.timetrend)[2] * time) + coef(m.timetrend)[1]
#     fixed.3             <- ly1 
#     tocorrect           <- fixed.2 < max(na.omit(ly1))
#     tocorrect[is.na(tocorrect)]<-FALSE
#     fixed.3[tocorrect]  <- fixed.2[tocorrect]
#     return(fixed.3)
#     }"""
#     return convert(Array{T, 1}, rcall(:bias_correction_R, radiance, clouds))
# end

"""
The bias correction function can use the datacubes of radiance and the number of cloud-free observations to correct for attenuation in radiance due to low number of cloud-free observations. 
```julia
bias_correction(radiance, clouds)
```
"""
function bias_correction(radiance_datacube::Array{T, 3}, clouds_datacube, mask=ones(Int8, (size(radiance_datacube)[1],size(radiance_datacube)[2]))) where T <: Real
    rad_corrected_datacube = radiance_datacube
    @showprogress for i in 1:size(radiance_datacube)[1]
        for j in 1:size(radiance_datacube)[2]
            if counter_nan(radiance_datacube[i, j, :])/length(radiance_datacube[i, j, :]) > 0.50 
                continue
            end
            if mask[i, j]==0
                continue
            end
            radiance_arr = radiance_datacube[i, j, :]
            clouds_arr = clouds_datacube[i , j, :]
            if rank_correlation_test(radiance_arr, clouds_arr) <0.05
                rad_corrected_datacube[i, j, :]= bias_correction(radiance_arr, clouds_arr)
            else
                rad_corrected_datacube[i, j, :]= radiance_arr
            end
        end
    end
    return rad_corrected_datacube
end
