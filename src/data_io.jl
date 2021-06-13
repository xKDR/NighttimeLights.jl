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

function save_img(filepath,img)
    GeoArrays.write!(filepath,GeoArray(convert(Array{Float32},img')))
end

function load_datacube(datacube_path)
    datacube = load(datacube_path)["data"]
    return datacube
end

function save_datacube(filepath,datacube)
    save(filepath, "data", datacube)
end