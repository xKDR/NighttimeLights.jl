For accurate economic inference using nighttime lights data, it's essential to perform thorough data cleaning. The rationale behind this process is elaborated in the work `"But clouds got in my way: Bias and bias correction of VIIRS nighttime lights data in the presence of clouds" by Patnaik, Ayush et al. (2021)`

Additionally, a comprehensive description of the API can be found in the paper `"Foundations for nighttime lights data analysis" by Patnaik, Ayush, Ajay Shah, and Susan Thomas (2022)`

```@docs
na_recode(radiance, ncfobs; replacement)
na_interp_linear(timeseries)
outlier_variance(datacube, mask)
outlier_hampel(timeseries, window_size = 5, n_sigmas = 3)
bgnoise_PSTT2021(radiance_datacube, ncfobs_datacube, th = 0.4)
bias_PSTT2021(radiance, ncfobs, smoothing_parameter=10.0) 
bias_PSTT2021(radiance_datacube, ncfobs_datacube, mask)
PSTT2021_conventional(radiance_datacube, ncfobs_datacube)
PSTT2021(radiance_datacube, ncfobs_datacube)
clean_complete(radiance_datacube, ncfobs_datacube)
```
