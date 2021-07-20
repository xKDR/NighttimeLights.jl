# Tutorial

The following example demonstrates how to use nighttime lights data for research. First the dataset is cleaned and then aggregate of polygons are produced. The following tutorial shows the cleaning procedure for nighttime lights of a box around Mumbai and then the time series of aggregate radiance for each district of Mumbai is generated. The radiance and cloud-free observations datacubes for Mumbai and the district level shapefiles for Mumbai can be downloaded from [assets provided with the package](https://github.com/JuliaPlanet/NighttimeLights.jl/tree/main/assets)

# Cleaning Data

##### 1. Load datacubes
The datacubes for Mumbai city are provided with the package to demonstrate this tutorial. The datacubes contain 156 rows, 85 columns for 95 months. 

[Radiance datacube of Mumbai](https://github.com/JuliaPlanet/NighttimeLights.jl/blob/main/assets/mumbai_ntl/datacube/mumbai_radiance.jld)

[The cloud-free observations datacube of Mumbai](https://github.com/JuliaPlanet/NighttimeLights.jl/blob/main/assets/mumbai_ntl/datacube/mumbai_clouds.jld)
```
radiance_datacube = load_datacube("assets/mumbai_ntl/datacube/mumbai_radiance.jld")
radiance_clouds = load_datacube("assets/mumbai_ntl/datacube/mumbai_clouds.jld")
```
##### 2. Replace observations with 0 cloud-free observations with NaN.
Monthly averages with 0 measurements are marked as 0 in the radiance datacube, they should be NaN. 
```julia
radiance_datacube = mark_nan(radiance_datacube, clouds_datacube) 
```
##### 3. Replace all values below 0 with NaN
There are negative values in the data due to cleaning procedure by NOAA. They should be replaced by NaN. 
```julia
radiance_datacube = replace!(x -> x < 0 ? NaN : x, radiance_datacube) 
```
##### 4. Generate a background noise mask. 
All the pixels below 0.4 in the annual image of the 12 months of the data will be considered background noise. A different threshold can be chosen. 
```
noise = background_noise_mask(datacube, clouds_datacube, 0.4)
radiance_datacube = apply_mask(datacube, noise)
```
All the pixels considered dark in the noise mask have all observations marked as 0 in the datacube.
##### 5. Generate an outlier mask.
The noise_mask is used as a parameter, so only the pixels considered lit are used to estimating the outliers pixels. 
```
stable_pixels = outlier_mask(radiance_datacube, noise)
radiance_datacube = apply_mask(datacube, stable_pixels)
```
All the pixels considered outliers have all observations marked as 0 in the datacube.
##### 6. Remove outlier observations from the remaining pixels. 
```
radiance_datacube = long_apply(outlier_ts, datacube)
```
The ```long_apply``` function applies the outlier_ts function on each pixel. This removal outlier observations from pixels which are useful. 
##### 7. Correct of attenuation due to clouds 
```julia
mask = noise .* stable_pixels # Mask of pixels with are lit and aren't outliers. 
radiance_datacube = bias_correction(radiance_datacube, clouds_datacube, mask)
```
Attenuation correction is only done on pixels which are considered lit in both the outlier mask and the noise mask. 
##### 8. Use linear interpolation to fill the NaNs.
```julia
radiance_datacube = long_apply(linear_interpolation, radiance_datacube)
```
Even though this is done for all pixels, the ones considered dark in the mask will be zero. 

# Generating Aggregates

##### 1. Make a coordinate system of Mumbai. 
The top left pixel of the box around Mumbai datacube, which we have used so far, have coordinates (19.49907,72.721252). The bottom right pixel's coordinates are (18.849475, 73.074187). There are 156 rows and 85 columns in the datacube. The number of months of data doesn't matter in calculating the coordinate system.  

```julia
MUMBAI_COORDINATE_SYSTEM = CoordinateSystem(Coordinate(19.49907,72.721252), (18.849475, 73.074187), 156, 85)
```
This coordinate system is predefined, you can just use the global variable ```MUMBAI_COORDINATE_SYSTEM```. 
##### 2. Load the shape file for the districts of Mumbai. 
[The district level shapefile of Mumbai](https://github.com/JuliaPlanet/NighttimeLights.jl/tree/main/assets/mumbai_map) 
These have been downloaded from datameet. 
```julia
mumbai_map = load_shapefile("assets/mumbai_map/mumbai_districts.shp")
```
The shapefile has a column called DISTRICT. For each district, the name of the district is shown in this column. Will be used this column as column names of the dataset that we'll generate in the next step. We could have also used census code or any other column with unique names. 

##### 3. Generate the time series of aggregate radiance for each district of Mumbai. 
```julia
mumbai_district_ntl = aggregate_dataframe(MUMABI_COORDINATE_SYSTEM, radiance_datacube, mumbai_map, "DISTRICT")
``` 
