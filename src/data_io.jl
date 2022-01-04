"""
NOAA provides nighttime lights images as tif files. They can be opened as 2D arrays using the load_img function. 
```julia
load_img("example.tif")
```
"""
function load_img(filepath)
    img = ArchGDAL.read((ArchGDAL.read(filepath)),1)
    img_trans = img' #tif loaded using ArchGDAL needs to be transposed
    return Array{Union{Missing, Float16}, 2}(img_trans) 
end

"""
Images in the form of 2D arrays can be saved as tif files. 
```julia
save_img("example.tif", img)
```
"""
function save_img(filepath,img)
    GeoArrays.write!(filepath,GeoArray(img'))
end

"""
NOAA provides images for each month since April 2012. Images of the same place taken at different times can be stacked together to make a 3D array representating a panel data. In this package, we refer to such arrays as datacubes. JLD files containing 3D arrays can be loaded using the load_datacube function.  
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
```julia
save_datacube("example.jld", datacube)
```
"""
function save_datacube(filepath, datacube)
    save(filepath, "data", datacube)
end

"""
Loads all images (tif files) in a folder and generates a datacube. The function prints the file names to you the order in which they are loaded. 
```julia
make_datacube("~/Downloads/ntl_images")
```
"""
function make_datacube(folder_path)
        files = readdir(folder_path)
        print(files)
        paths = folder_path .* "/".* files 
        datacube = []
        for path in paths
            push!(datacube, load_img(path))
        end
        return Array{Union{Missing, Float16}, 3}(cat(datacube...,dims = 3))
end


