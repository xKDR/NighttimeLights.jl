Using nighttime lights for economic inference needs cleaning of the data.   

There are negative observations in the data as a consequence of NOAA's cleaning procedures. Many researchers replace them with 0. It can be done using the following:
```julia
datacube = replace!(x -> x < 0 ? 0 : x, datacube) # replace all values below 0 with 0
```
These values can be replaced with missing and interpolated. 
```julia
datacube = replace!(x -> x < 0 ? missing : x, datacube) # replace all values below 0 with missing
```

```@docs
mark_missing(radiance, clouds::Array{T, 2}) where T <: Any
mark_missing(radiance, clouds::Array{T, 3}) where T <: Any
linear_interpolation(timeseries)
outlier_mask(datacube, mask)
outlier_ts(timeseries, window_size = 5, n_sigmas = 3)
background_noise_mask(radiance_datacube, clouds_datacube, th = 0.4)
PSTT2021_biascorrect(radiance, clouds::Array{T, 1}, smoothing_parameter=10.0) where T <: Any
PSTT2021_biascorrect(radiance_datacube, clouds_datacube::Array{T, 3}, mask=ones(Int8, (size(radiance_datacube)[1],size(radiance_datacube)[2]))) where T <: Any
PSTT2021_conventional(radiance_datacube, clouds_datacube)
PSTT2021(radiance_datacube, clouds_datacube)


```
