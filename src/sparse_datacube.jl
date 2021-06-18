function sparse_cube(datacube)
    radiance = []
    for i in 1:size(datacube)[3]
        push!(radiance,sparse(datacube[:,:,i]))
    end
    return VectorOfArray(radiance)
end
