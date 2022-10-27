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
na_recode(radiance, clouds::Array{T, 2}) where T <: Any
na_recode(radiance, clouds::Array{T, 3}) where T <: Any
na_interp_linear(timeseries)
outlier_variance(datacube, mask)
outlier_hampel(timeseries, window_size = 5, n_sigmas = 3)
bgnoise_PSTT2021(radiance_datacube, clouds_datacube, th = 0.4)
bias_PSTT2021(radiance, clouds::Array{T, 1}, smoothing_parameter=10.0) where T <: Any
bias_PSTT2021(radiance_datacube, clouds_datacube::Array{T, 3}, mask=ones(Int8, (size(radiance_datacube)[1],size(radiance_datacube)[2]))) where T <: Any
PSTT2021_conventional(radiance_datacube, clouds_datacube)
PSTT2021(radiance_datacube, clouds_datacube)


```
