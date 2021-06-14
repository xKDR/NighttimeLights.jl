module NighttimeLights

# Write your package code here.
using ArchGDAL
using GeoArrays
using DataFrames
using Shapefile
using Luxor
using GeoInterface
using GeometricalPredicates
using ProgressMeter
using SparseArrays
using StatsBase
using Loess
using CubicSplines

export load_img, load_datacube, save_img, save_datacube
include("data_io.jl")
export lat_to_row, row_to_lat, lat_to_row, long_to_column, translate_coordinate_system, Coordinate, CoordinateSystem, india
include("coordinate_system.jl")
export polygon_mask, load_shapefile, mask_area, LAT, EW, NS, MODEL_EW, MODEL_NS
include("polygons.jl")
end
