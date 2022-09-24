```julia
using Plots
plot(raster)
```
![raster](rasterworld.png)

```julia
mumbaibox_radiance = crop(raster; to = mumbai_map.geometry)
plot(mumbaibox_radiance)
```
![raster](mumbaibox.png)
```julia
mumbai_radiance = mask(mumbaibox_radiance, with = mumbai_map.geometry)
plot(mumbai_radiance)
```
![raster](mumbai_radiance.png)
