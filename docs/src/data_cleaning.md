Using nighttime lights for economic inference needs cleaning of the data. 

```@docs
linear_interpolation(timeseries)
```

```@docs
outlier_mask(datacube, mask)
```

```@docs
outlier_ts(timeseries)
```

There are negative observations in the data as a consequence of NOAA's cleaning procedures. Many researchers replace them with 0. It can be done using the following:
```julia
datacube = replace!(x -> x < 0 ? 0 : x, datacube) # replace all values below 0 with 0
```
These values can be replaced with NaN and interpolated. 
```julia
datacube = replace!(x -> x < 0 ? NaN : x, datacube) # replace all values below 0 with NaN
```

```@docs
background_noise_mask(datacube=radiance_datacube, clouds=clouds_datacube, th=0.4)
```

