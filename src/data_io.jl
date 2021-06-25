"""
NOAA provides nighttime lights images as tif files. They can be opened as 2D arrays using the load_img function. 
# Example:
```julia
load_img("example.tif")
```
"""
function load_img(filepath)
    img = ArchGDAL.read((ArchGDAL.read(filepath)),1)
    img_trans = img' #tif loaded using ArchGDAL needs to be transposed
    return convert(Array{Float16,2},img_trans) 
end

function load_img(radiance_filepath,clouds_filepath)
    radiance = load_img(radiance_filepath)
    clouds = load_img(clouds_filepath)
    clouds = convert(Array{Int8},clouds)
    for i in 1:size(clouds)[1]
        for j in 1:size(clouds)[2]
            if clouds[i,j] == 0
                radiance[i,j]=NaN
            end
        end
    end
    return radiance
end

"""
Images in the form of 2D arrays can be saved as tif files. 
# Example:
```julia
save_img("example.tif", img)
```
"""
function save_img(filepath,img)
    GeoArrays.write!(filepath,GeoArray(convert(Array{Float32},img')))
end

"""
NOAA provides images for each month since April 2012. Images of the same place taken at different times can be stacked together to make a 3D array representating a panel data. In this package, we refer to such arrays as datacubes. JLD files containing 3D arrays can be loaded using the load_datacube function.  

# Example:
```julia
load_datacube("example.jld")
```
"""
function load_datacube(datacube_path)
    datacube = load(datacube_path)["data"]
    return datacube
end

"""
3D arrays can be saved as JLD files. 
# Example:
```julia
save_datacube("example.jld", datacube)
```
"""
function save_datacube(filepath, datacube)
    save(filepath, "data", datacube)
end