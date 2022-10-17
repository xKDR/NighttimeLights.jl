"""
`centre_of_mass` finds the mean of coordinates weighted by nighttime lights radiance_datacube. 

```julia
using Rasters
load_example()
img = view(radiance_datacube, Ti(1))
centre_of_mass(img)
```
"""
function centre_of_mass(raster)
    com = Tuple(zeros(ndims(raster))) # initializing
    for i in CartesianIndices(raster)
        if ismissing(raster[i])
            continue
        end
        com = com .+ Tuple(i) .* raster[i]
    end
    (xcom_index, ycom_index) =Int.(round.(com ./ sum(skipmissing(raster))))
    return map(getindex, dims(raster), [xcom_index, ycom_index]) # longitude and latitude of the centre of mass
end