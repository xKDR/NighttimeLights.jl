
@testset "testing input output functions" begin 
    package_path = pathof(NighttimeLights)
    path_len = length(package_path)
    assets_path = package_path[1:path_len-22] * "assets"
    map_path = assets_path * "/mumbai_map/mumbai_districts.shp"
    radiance_jld_path = assets_path * "/mumbai_ntl/datacube/mumbai_radiance.jld"
    radiance_img_path = assets_path * "/mumbai_ntl/img/april2012.tif"
    @test length(size(load_datacube(radiance_jld_path))) == 3
    @test length(size(load_img(radiance_img_path))) == 2
    @test length(size(load_img(radiance_img_path ,[10, 10], [50, 50]))) == 2
    @test sizeof(load_shapefile(map_path)) > 0
    datacube_path = assets_path * "/mumbai_ntl/img"
    @test make_datacube(datacube_path)[:,:,1] == load_img(radiance_img_path)
    @test make_datacube(datacube_path,[10, 10], [50, 50])[:,:,1] == load_img(radiance_img_path,[10, 10], [50, 50])
    @test make_datacube(datacube_path, Coordinate( 19.109979, 72.857009 ), Coordinate( 19.004297, 72.895921 ), MUMBAI_COORDINATE_SYSTEM)[:,:,1] == load_img(radiance_img_path, Coordinate( 19.109979, 72.857009 ), Coordinate( 19.004297, 72.895921 ), MUMBAI_COORDINATE_SYSTEM)
    load_example()
    bbox = bounding_box(mumbai_map[2, :].geometry)
    @test make_datacube(datacube_path, bbox, MUMBAI_COORDINATE_SYSTEM)[:,:,1] == load_img(radiance_img_path, bbox, MUMBAI_COORDINATE_SYSTEM)
end