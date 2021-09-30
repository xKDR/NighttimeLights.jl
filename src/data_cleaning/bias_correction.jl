"""
Clouds months tends to have lower radiance due to attenuation. The bias_correction function uses the number of cloud-free observations to adjust the radiance accordingly. 
```julia
bias_correction(radiance, clouds)
```
"""
function bias_correction(radiance::Array{T, 1}, clouds) where T <: Real
    if rank_correlation_test(radiance, clouds) > 0.05 # Don't perform correction is p-value of rank correlation > 0.05
        return radiance
    end
    log_radiance = log.(radiance) 
    ys = log_radiance
    ys = detrend_ts(ys)
    time_trend = log_radiance .- ys
    xs = clouds
    xs = xs/maximum(xs)
    model = loess(xs, ys)
    vs = Loess.predict(model, xs)
    top_val = vs[findmax(xs)[2]]
    for i in 1:length(ys)
        if ys[i]<top_val
            ys[i] = ys[i] + top_val - vs[i]
        end
    end
    ys = ys .+ time_trend
    ys = exp.(ys)
    return ys 
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
            if counter_nan(radiance_datacube[i, j, :])/length(radiance_datacube[i, j, :]) > 0.50 
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
