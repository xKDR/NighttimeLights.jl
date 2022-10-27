function make_sparse(raster)
    arr = Array(raster[:,:,1])
    replace!(arr, missing => 0)
    sparse(arr)
end
"""
`centre_of_mass` finds the mean of coordinates weighted by nighttime lights radiance_datacube. 

```julia
using Rasters
using SparseArrays
load_example()
img = view(radiance_datacube, Ti(1))
spaster = sparse(Array(img)[:,:,1])
centre_of_mass(spaster, dims(img))
```
"""
function centre_of_mass(raster, dimensions)
    nz = findnz(raster)
    xcom_index = Int(round(sum((nz[1] .* nz[3])) / sum(nz[3])))
    ycom_index = Int(round(sum((nz[2] .* nz[3])) / sum(nz[3])))
    return map(getindex, dimensions, [xcom_index, ycom_index]) # longitude and latitude of the centre of mass
end

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
    spaster = make_sparse(raster)
    centre_of_mass(spaster, dims(raster))
end