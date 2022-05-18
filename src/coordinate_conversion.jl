"""
To convert from latitude to row number of an image, use the ```lat_to_row``` function. 
# Example: 
```julia
lat_to_row(my_coordinate_system, 19.6) 
```
"""
function lat_to_row(geometry::CoordinateSystem, x)
    top_left        = geometry.top_left.latitude
    bottom_right    = geometry.bottom_right.latitude
    height          = geometry.height  
    return Int(round(((x - top_left) * height / (bottom_right - top_left))))
end
"""
To convert from longitude to column number of an image use the ```long_to_column``` function. 
# Example:
```julia
long_to_column(my_coordinate_system, 73.33) 
```
"""
function long_to_column(geometry::CoordinateSystem, x)
    top_left        = geometry.top_left.longitude
    bottom_right    = geometry.bottom_right.longitude
    width           = geometry.width  
    return Int(round(((x - top_left) * width/(bottom_right - top_left))))
end
"""
To convert from row number of an image to latitude use the ```row_to_lat``` function. 
# Example:
```julia
row_to_lat(my_coordinate_system, 100) 
```
"""
function row_to_lat(geometry::CoordinateSystem, x)
    top_left        = geometry.top_left.latitude
    bottom_right    = geometry.bottom_right.latitude
    height          = geometry.height
    return  ((bottom_right - top_left)/height * x + top_left)
end
"""
To convert from column number of an image to longitude use the ```column_to_long``` function.
# Example: 
```julia
column_to_long(my_coordinate_system, 100) 
```
"""
function column_to_long(geometry::CoordinateSystem, x)
    top_left        = geometry.top_left.longitude
    bottom_right    = geometry.bottom_right.longitude
    width           = geometry.width  
    return((bottom_right - top_left)/width * x + top_left)
end

"""
To convert a coordinate from earth's coordinate system to image's row number and column number, use the ```coordinate_to_image``` function. 
# Example: 
```julia
coordinate_to_image(my_coordinate_system, Coordinate(19.49907, 72.721252)) 
```
"""
function coordinate_to_image(geometry::CoordinateSystem, x::Coordinate)
    return [lat_to_row(geometry, x.latitude), long_to_column(geometry, x.longitude)]
end
"""
To convert a coordinate from image's row number and column number to earth's coordinate system use the ```image_to_coordinate``` function. 
# Example: 
```julia
image_to_coordinate(my_coordinate_system, [4320, 1153]) 
```
"""
function image_to_coordinate(geometry::CoordinateSystem, x)
    return Coordinate(row_to_lat(geometry, x[1]), column_to_long(geometry, x[2]))
end


"""
Translates a coordinate system given the new top-left and bottom-right coordinates
# Example: 
```julia
MUMBAI = translate_geometry(INDIA_COORDINATE_SYSTEM, Coordinate(19.49907, 72.721252), Coordinate(18.849475, 73.074187))
```
"""
function translate_geometry(geometry::CoordinateSystem, top_left::Coordinate, bottom_right::Coordinate)
    top_left_row = lat_to_row(geometry, top_left.latitude)
    bottom_right_row = lat_to_row(geometry, bottom_right.latitude)
    bottom_right_col = long_to_column(geometry, bottom_right.longitude)
    top_left_col = long_to_column(geometry, top_left.longitude)
    height = round(bottom_right_row - top_left_row)
    width = round(bottom_right_col - top_left_col)
    return CoordinateSystem(top_left, bottom_right, height, width) 
end

"""
Translates a coordinate system given a bounding_box
# Example: 
```julia
MUMBAI = translate_geometry(INDIA_COORDINATE_SYSTEM, polygon_boundary)
```
"""
function translate_geometry(geometry::CoordinateSystem, polygon_boundary::PolygonBoundary)
    return translate_geometry(geometry, polygon_boundary.top_left, polygon_boundary.bottom_right)
end

global MUMBAI_COORDINATE_SYSTEM = translate_geometry(INDIA_COORDINATE_SYSTEM, Coordinate(19.49907, 72.721252), Coordinate(18.849475, 73.074187))