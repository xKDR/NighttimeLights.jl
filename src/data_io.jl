"""
NOAA provides nighttime lights images as tif files. They can be opened as 2D arrays using the ```load_img``` function. 
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
NOAA provides nighttime lights images as tif files. They can be opened as 2D arrays using the ```load_img``` function. The top-left and bottom-right parameters can be used to crop the image. 
```julia
load_img("example.tif")
```
"""
function load_img(filepath, top_left, bottom_right)
    img = ArchGDAL.readraster(filepath)
    img = img[top_left[2]+1:bottom_right[2], top_left[1]+1:bottom_right[1], 1]
    GC.gc()
    return Array{Union{Missing, Float16}, 2}(img')
end


"""
NOAA provides nighttime lights images as tif files. They can be opened as 2D arrays using the load_img function. The top-left and bottom-right parameters can be used to crop the image. 
```julia
load_img("example.tif")
```
"""
function load_img(filepath, top_left::Coordinate, bottom_right::Coordinate, geometry::CoordinateSystem)
    top_left = coordinate_to_image(geometry, top_left)
    bottom_right = coordinate_to_image(geometry, bottom_right)
    img = load_img(filepath, top_left, bottom_right)
    return img
end

"""
Images in the form of 2D arrays can be saved as tif files. 
```julia
save_img("example.tif", img)
```
"""
function save_img(filepath,img)
    img = Float64.(img)
    GeoArrays.write!(filepath,GeoArray(img'))
end

"""
NOAA provides images for each month since April 2012. Images of the same place taken at different times can be stacked together to make a 3D array representating a panel data. In this package, we refer to such arrays as datacubes. JLD files containing 3D arrays can be loaded using the ```load_datacube``` function.  
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
function make_datacube(folder_path, display_names = false)
        files = readdir(folder_path)
        if display_names == true
            print(files)
        end
        paths = folder_path .* "/".* files 
        datacube = []
        for path in paths
            push!(datacube, load_img(path))
        end
        return Array{Union{Missing, Float16}, 3}(cat(datacube...,dims = 3))
end

"""
Loads all images (tif files) in a folder and generates a datacube. The function prints the file names to you the order in which they are loaded. The ```top_left``` and the ```bottom_right``` parameters can be used to crop the datacube.  
```julia
make_datacube("~/Downloads/ntl_images", [0, 0] ,[10, 10])
```
"""
function make_datacube(folder_path, top_left, bottom_right; display_names = false)
        files = readdir(folder_path)
        if display_names == true
            display(files)
        end
        paths = folder_path .* "/".* files 
        datacube = []
        for path in paths
            push!(datacube, load_img(path, top_left, bottom_right))
        end
        return Array{Union{Missing, Float16}, 3}(cat(datacube...,dims = 3))
end

"""
Loads all images (tif files) in a folder and generates a datacube. The function prints the file names to you the order in which they are loaded. The ```top_left``` and the ```bottom_right``` parameters can be used to crop the datacube. You need a coordinate system in the ```top_left``` and ```bottom_right``` are coordinates of the the earth. 
```julia
make_datacube("~/Downloads/ntl_images", Coordinate(19.49907, 72.721252), Coordinate(18.849475, 73.074187), TILE3_COORDINATE_SYSTEM)
```
"""
function make_datacube(folder_path, top_left::Coordinate, bottom_right::Coordinate, geometry::CoordinateSystem; display_names = false)
        files = readdir(folder_path)
        if display_names == true
            display(files)
        end
        paths = folder_path .* "/".* files 
        datacube = []
        for path in paths
            push!(datacube, load_img(path, top_left, bottom_right, geometry))
        end
        return Array{Union{Missing, Float16}, 3}(cat(datacube...,dims = 3))
end

"""
Loads all images (tif files) in a folder and generates a datacube. The function prints the file names to you the order in which they are loaded. You can use a coordinate system for cropping.  
```julia
make_datacube("~/Downloads/ntl_images",  TILE3_COORDINATE_SYSTEM, INDIA_COORDINATE_SYSTEM)
```
"""
function make_datacube(folder_path, g1::CoordinateSystem, g2::CoordinateSystem; display_names = false)
        files = readdir(folder_path)
        if display_names == true
            display(files)
        end
        paths = folder_path .* "/".* files 
        datacube = []
        for path in paths
            push!(datacube, load_img(path, g2.top_left, g2.bottom_right, g1))
        end
        return Array{Union{Missing, Float16}, 3}(cat(datacube...,dims = 3))
end

"""
Loads all images (tif files) in a folder and generates a datacube. The function prints the file names to you the order in which they are loaded. The bounding box of a Polygon can be used to crop the datacube. You also need a coordinate reference system. 
"""
function make_datacube(folder_path, polygon_boundary::PolygonBoundary, 
    geometry::CoordinateSystem; display_names = false)
        top_left = polygon_boundary.top_left
        bottom_right = polygon_boundary.bottom_right
        files = readdir(folder_path)
        if display_names == true
            display(files)
        end
        paths = folder_path .* "/".* files 
        datacube = []
        for path in paths
            push!(datacube, load_img(path, top_left, bottom_right, geometry))
        end
        return Array{Union{Missing, Float16}, 3}(cat(datacube...,dims = 3))
end