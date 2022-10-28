Using nighttime lights for economic inference needs cleaning of the data.   

```@docs
na_recode(radiance, clouds; replacement)
na_interp_linear(timeseries)
outlier_variance(datacube, mask)
outlier_hampel(timeseries, window_size = 5, n_sigmas = 3)
bgnoise_PSTT2021(radiance_datacube, clouds_datacube, th = 0.4)
bias_PSTT2021(radiance, clouds, smoothing_parameter=10.0) 
bias_PSTT2021(radiance_datacube, clouds_datacube, mask)
PSTT2021_conventional(radiance_datacube, clouds_datacube)
PSTT2021(radiance_datacube, clouds_datacube)
clean_complete(radiance_datacube, clouds_datacube)
```
