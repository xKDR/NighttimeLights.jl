"""
Clouds months tends to have lower radiance due to attenuation. The bias_correction function uses the number of cloud-free observations to adjust the radiance accordingly. 
```julia
bias_correction(radiance, clouds)
```
"""
function bias_correction(radiance, clouds::Array{T, 1}, smoothing_parameter=10.0) where T <: Real
    missings = findall(ismissing, radiance)
    y = filter!(!ismissing, copy(radiance))
    x = Array{Union{Float64, Missing}}(copy(clouds))
    x[missings] .= missing
    x = Array{Float64}(filter!(!ismissing, x))
    y_ = Array{Float64}(detrend_ts(y))
    m = predict(fit(SmoothingSpline, x, y_, smoothing_parameter), x)
    topval = maximum(m)
    fixed1 = y_ -m .+ topval
    fixed2 = fixed1 + y - y_ # adding the time trend
    for i in 1:length(y)
        if fixed2[i] > maximum(y)
            fixed2[i] = y[i]
        end
    end
    fixed2 = Array{Union{Float64, Missing}}(fixed2)
    for i in missings #putting back the missing values
        fixed2 = insert!(fixed2, i, missing)
    end
    return fixed2
end

"""
The bias correction function can use the datacubes of radiance and the number of cloud-free observations to correct for attenuation in radiance due to low number of cloud-free observations. 
```julia
bias_correction(radiance, clouds)
```
"""
function bias_correction(radiance_datacube, clouds_datacube::Array{T, 3}, mask=ones(Int8, (size(radiance_datacube)[1],size(radiance_datacube)[2]))) where T <: Real
    rad_corrected_datacube = radiance_datacube
    @showprogress for i in 1:size(radiance_datacube)[1]
        for j in 1:size(radiance_datacube)[2]
            if count(i->(ismissing(i)),radiance_datacube[i, j, :])/length(radiance_datacube[i, j, :]) > 0.50 
                continue
            end
            if mask[i, j]==0
                continue
            end
            missings = findall(ismissing, radiance_datacube[i, j, :])
            radiance_arr = filter!(!ismissing, copy(radiance_datacube[i, j, :])) 
            clouds_arr = Array{Union{Float64, Missing}}(copy(clouds_datacube[i , j, :]))
            clouds_arr[missings] .= missing
            clouds_arr = filter!(!ismissing, clouds_arr)
            if rank_correlation_test(radiance_arr, clouds_arr) <0.05
                rad_corrected_datacube[i, j, :]= bias_correction(copy(radiance_datacube[i, j, :]), copy(clouds_datacube[i , j, :]))
            else
                rad_corrected_datacube[i, j, :]= radiance_datacube[i, j, :]
            end
        end
    end
    return rad_corrected_datacube
end
