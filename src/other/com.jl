function make_sparse(raster)
    arr = Array(raster[:,:,1])
    replace!(arr, missing => 0)
    sparse(arr)
end
"""
`centre_of_mass` finds the mean of coordinates weighted by nighttime lights radiance_datacube. 

```julia
spaster = sparse(Array(radiance_image)[:,:,1])
centre_of_mass(spaster, dims(radiance_image))
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
centre_of_mass(radiance_image)
```
"""
function centre_of_mass(raster)
    spaster = make_sparse(raster)
    centre_of_mass(spaster, dims(raster))
end