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
 
function lat_to_row(coordinate_system::CoordinateSystem, x)
    top_left        = coordinate_system.top_left.latitude
    bottom_right    = coordinate_system.bottom_right.latitude
    height          = coordinate_system.height  
    return ((x - top_left) * height / (bottom_right - top_left))
end

function long_to_column(coordinate_system::CoordinateSystem, x)
    top_left        = coordinate_system.top_left.longitude
    bottom_right    = coordinate_system.bottom_right.longitude
    width           = coordinate_system.width  
    return ((x - top_left) * width/(bottom_right - top_left))
end

function row_to_lat(coordinate_system::CoordinateSystem, x)
    top_left        = coordinate_system.top_left.latitude
    bottom_right    = coordinate_system.bottom_right.latitude
    height          = coordinate_system.height
    return  ((bottom_right - top_left)/height * x + top_left)
end

function column_to_long(coordinate_system::CoordinateSystem, x)
    top_left        = coordinate_system.top_left.longitude
    bottom_right    = coordinate_system.bottom_right.longitude
    width           = coordinate_system.width  
    return((bottom_right - top_left)/width * x + top_left)
end

function translate_coordinate_system(coordinate_system::CoordinateSystem,top_left::Coordinate,bottom_right::Coordinate)
    top_left_row = lat_to_row(coordinate_system, top_left.latitude)
    bottom_right_row = lat_to_row(coordinate_system, bottom_right.latitude)
    bottom_right_col = long_to_column(coordinate_system,bottom_right.longitude)
    top_left_col = long_to_column(coordinate_system, top_left.longitude)
    height = round(top_left_col - bottom_right_col)
    width = round(top_left_row - bottom_right_row)
    return CoordinateSystem(top_left, bottom_right, height, width) 
end
india = CoordinateSystem(Coordinate(37.5, 67.91666), Coordinate(4.166, 97.5), 8000, 7100)
