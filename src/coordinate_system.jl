struct Coordinate
    latitude
    longitude
end

struct CoordinateSystem
    """
    Enter coorindate(lat,long) for top_left and bottom_right. Enter the height and width of the images in number of pixels. 
    """
    top_left::Coordinate
    bottom_right::Coordinate 
    height::Int64
    width::Int64
end
 
function lat_to_row(geometry::CoordinateSystem, x)
    top_left        = geometry.top_left.latitude
    bottom_right    = geometry.bottom_right.latitude
    height          = geometry.height  
    return ((x - top_left) * height / (bottom_right - top_left))
end

function long_to_column(geometry::CoordinateSystem, x)
    top_left        = geometry.top_left.longitude
    bottom_right    = geometry.bottom_right.longitude
    width           = geometry.width  
    return ((x - top_left) * width/(bottom_right - top_left))
end

function row_to_lat(geometry::CoordinateSystem, x)
    top_left        = geometry.top_left.latitude
    bottom_right    = geometry.bottom_right.latitude
    height          = geometry.height
    return  ((bottom_right - top_left)/height * x + top_left)
end

function column_to_long(geometry::CoordinateSystem, x)
    top_left        = geometry.top_left.longitude
    bottom_right    = geometry.bottom_right.longitude
    width           = geometry.width  
    return((bottom_right - top_left)/width * x + top_left)
end

function translate_geometry(geometry::CoordinateSystem,top_left::Coordinate,bottom_right::Coordinate)
    top_left_row = lat_to_row(geometry, top_left.latitude)
    bottom_right_row = lat_to_row(geometry, bottom_right.latitude)
    bottom_right_col = long_to_column(geometry,bottom_right.longitude)
    top_left_col = long_to_column(geometry, top_left.longitude)
    height = round(top_left_col - bottom_right_col)
    width = round(top_left_row - bottom_right_row)
    return CoordinateSystem(top_left, bottom_right, height, width) 
end
global india = CoordinateSystem(Coordinate(37.5, 67.91666), Coordinate(4.166, 97.5), 8000, 7100)
