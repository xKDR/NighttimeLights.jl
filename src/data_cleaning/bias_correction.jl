"""
Cloudy months tends to have lower radiance due to attenuation. The bias_PSTT2021 function uses the number of cloud-free observations to adjust the radiance accordingly. 
```julia
bias_PSTT2021(radiance_pixel_ts, ncfobs_pixel_ts)
```
"""
function bias_PSTT2021_pixel(radiance_pixel_ts, ncfobs_pixel_ts, smoothing_parameter=10.0)
    missings = findall(ismissing, radiance_pixel_ts)
    y = filter!(!ismissing, copy(Array(radiance_pixel_ts)))
    x = Array{Union{Float64, Missing}}(copy(ncfobs_pixel_ts))
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
bias_PSTT2021(radiance_datacube, ncfobs_datacube)
```
"""
function bias_PSTT2021(radiance_datacube, ncfobs_datacube, mask=ones(Int8, (size(radiance_datacube)[1],size(radiance_datacube)[2])))
    for i in 1:size(radiance_datacube)[1]
        for j in 1:size(radiance_datacube)[2]
            if count(i->(ismissing(i)),radiance_datacube[i, j, :])/length(radiance_datacube[i, j, :]) > 0.90 
                continue
            end
            if ismissing(mask[i, j])
                continue
            end
            missings = findall(ismissing, radiance_datacube[i, j, :])
            radiance_arr = filter!(!ismissing, copy(Array(radiance_datacube[i, j, :])) )
            ncfobs_arr = copy(Array(ncfobs_datacube[i , j, :]))
            ncfobs_arr = Array{Union{Missing, Int}}(ncfobs_arr)
            ncfobs_arr[missings] .= missing
            ncfobs_arr = filter!(!ismissing, ncfobs_arr)
            if rank_correlation_test(radiance_arr, ncfobs_arr) <0.05
                radiance_datacube[i, j, :]= bias_PSTT2021_pixel(copy(radiance_datacube[i, j, :]), copy(ncfobs_datacube[i , j, :]))
            else
                radiance_datacube[i, j, :]= radiance_datacube[i, j, :]
            end
        end
    end
    return radiance_datacube
end
