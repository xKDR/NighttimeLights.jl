# Mumbai tutorial

The following example demonstrates how to use nighttime lights data for research. First the dataset is cleaned and then aggregate of polygons are produced. The following tutorial shows the cleaning procedure for nighttime lights of a box around Mumbai and then the time series of aggregate radiance for each district of Mumbai is generated. 

# Cleaning Data

1. Load the radiance and clouds datacubes 
```julia
radiance_datacube = load_datacube("assets/mumbai_ntl/datacube/mumbai_radiance.jld")
radiance_clouds = load_datacube("assets/mumbai_ntl/datacube/mumbai_clouds.jld")
```
2. Replace observations with 0 cloud-free observations with NaN. 
```julia
radiance_datacube = mark_nan(radiance_datacube, clouds_datacube) 
```
3. Replace all values below 0 with NaN
```julia
datacube = replace!(x -> x < 0 ? NaN : x, datacube) 
```
4. Generate a background noise mask. A threshold of 0.4 is recommened.
```
noise = background_noise_mask(datacube, clouds_datacube, 0.4)
```
5. Apply the noise mask on the datacube so that all the pixels considered dark in the noise mask have all observations marked as 0 in the datacube. 
```julia
radiance_datacube = apply_mask(datacube, noise)
```
6. Generate and outlier mask. The noise_mask as a parameter, so only the pixels considered lit are used to estimating the outliers pixels. 
```
outliers = outlier_mask(radiance_datacube, noise)
```
7. Apply the outlier mask on the datacube so that all the pixels considered outliers in the mask have all observations marked as 0 in the datacube. 
```julia
radiance_datacube = apply_mask(datacube, outliers)
```
Now both outliers pixels and background noise pixels have been removed.
8. Remove outlier observations from all the remaining pixels. 
```
radiance_datacube = long_apply(outlier_ts, datacube)
```
The long_apply function applies the outlier_ts function on each pixel. 
9. Correct of attenuation due to clouds using the bias_correction function 
```julia
mask = noise .* outliers
radiance_datacube = bias_correction(radiance_datacube, clouds_datacube, mask)
```
attenuation correction is only done on pixel which considered lit in both the outlier mask and the noise mask. 
10. Use linear interpolation to fill for all the NaNs.
```julia
radiance_datacube = long_apply(linear_interpolation, radiance_datacube)
```

# Generating Aggregates

1. The coordinate system of Mumbai is predefined. 
```julia
MUMBAI_COORDINATE_SYSTEM
``` 
2. Load the shape file for the districts of Mumbai. 
```julia
mumbai_map = load_shapefile("assets/mumbai_map/mumbai_districts.shp")
```
The shapefile has a column called "DISTRICT". For each district, the name of the district is shown in this column. Will be used this column as column names of the dataset that we'll generate in the next step. We could have also district census code or any other column with unique names. 

3. Generate the time series of aggregate radiance for each district of Mumbai. 
```julia
mumbai_district_ntl = aggregate_dataframe(MUMABI_COORDINATE_SYSTEM, radiance_datacube, mumbai_map, "DISTRICT")
``` 

4. The district level aggregates have been generated. You can save the dataframe as a shapefile and use it in other places in you want. 