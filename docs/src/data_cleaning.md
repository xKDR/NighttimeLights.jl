Using nighttime lights for economic inference needs cleaning of the data.   

There are negative observations in the data as a consequence of NOAA's cleaning procedures. Many researchers replace them with 0. It can be done using the following:
```julia
datacube = replace!(x -> x < 0 ? 0 : x, datacube) # replace all values below 0 with 0
```
These values can be replaced with NaN and interpolated. 
```julia
datacube = replace!(x -> x < 0 ? NaN : x, datacube) # replace all values below 0 with NaN
```

```@docs
mark_nan(radiance::Array{T, 2}, clouds) where T <: Real
mark_nan(radiance_datacube::Array{T, 3}, clouds_datacube) where T <: Real
linear_interpolation(timeseries)
outlier_mask(datacube, mask)
outlier_ts(timeseries)
background_noise_mask(datacube=radiance_datacube, clouds=clouds_datacube, th=0.4)
bias_correction(radiance::Array{T, 1}, clouds) where T <:Real
bias_correction(radiance_datacube::Array{T, 3}, clouds_datacube, mask=ones(Int8, (size(radiance_datacube)[1],size(radiance_datacube)[2]))) where T <:Real
conventonal_cleaning(radiance_datacube, clouds_datacube)
PatnaikSTT2021(radiance_datacube, clouds_datacube)
```
