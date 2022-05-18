@testset "Testing functions on polygons and shapefiles" begin
package_path = pathof(NighttimeLights)
path_len = length(package_path)
assets_path = package_path[1:path_len-22] * "assets"
map_path = assets_path * "/mumbai_map/mumbai_districts.shp"

radiance_datacube = rand(1:100, 156, 85, 95)
mumbai_districts = load_shapefile(map_path)
@test nrow(mumbai_districts) > 0

district1 = mumbai_districts[1,:] # Select the first district
district1_mask = polygon_mask(MUMBAI_COORDINATE_SYSTEM, district1)

@test sum(district1_mask.vals) >=0 

end