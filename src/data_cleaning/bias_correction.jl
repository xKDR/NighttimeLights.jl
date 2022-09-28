"""
Clouds months tends to have lower radiance due to attenuation. The PSTT2021_biascorrect function uses the number of cloud-free observations to adjust the radiance accordingly. 
```julia
PSTT2021_biascorrect(radiance, clouds)
```
"""
function PSTT2021_biascorrect_pixel(radiance, clouds, smoothing_parameter=10.0)
    missings = findall(ismissing, radiance)
    y = filter!(!ismissing, copy(Array(radiance)))
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
PSTT2021_biascorrect(radiance, clouds)
```
"""
function PSTT2021_biascorrect(radiance_datacube, clouds_datacube, mask=ones(Int8, (size(radiance_datacube)[1],size(radiance_datacube)[2])))
    rad_corrected_datacube = Array(view(radiance_datacube, Band(1)))
    cf_dc = Array(view(clouds_datacube, Band(1)))
    for i in 1:size(rad_corrected_datacube)[1]
        for j in 1:size(rad_corrected_datacube)[2]
            if count(i->(ismissing(i)),rad_corrected_datacube[i, j, :])/length(rad_corrected_datacube[i, j, :]) > 0.50 
                continue
            end
            if ismissing(mask[i, j])
                continue
            end
            missings = findall(ismissing, rad_corrected_datacube[i, j, :])
            radiance_arr = filter!(!ismissing, copy(Array(rad_corrected_datacube[i, j, :])) )
            clouds_arr = copy(Array(cf_dc[i , j, :]))
            clouds_arr = Array{Union{Missing, Int}}(clouds_arr)
            clouds_arr[missings] .= missing
            clouds_arr = filter!(!ismissing, clouds_arr)
            if rank_correlation_test(radiance_arr, clouds_arr) <0.05
                rad_corrected_datacube[i, j, :]= PSTT2021_biascorrect_pixel(copy(rad_corrected_datacube[i, j, :]), copy(cf_dc[i , j, :]))
            else
                rad_corrected_datacube[i, j, :]= rad_corrected_datacube[i, j, :]
            end
        end
    end
    return Raster(add_dim(rad_corrected_datacube), dims(radiance_datacube))
end
