function long_apply(f, datacube::Array, mask = ones(size(datacube)[1], size(datacube)[2]))
    if ndims(f(datacube[1,1,:])) ==0
        new_matrix = Array{Float32}(undef, size(datacube, 1), size(datacube, 2))
        for i in 1:size(datacube)[1]
            for j in 1:size(datacube)[2]
                new_matrix[i, j] = f(datacube[i, j, :])
            end
        end
        return new_matrix
    else    
        new_matrix = Array{Float32}(undef, size(datacube, 1), size(datacube, 2),size(datacube)[3])
        @showprogress for i in 1:size(datacube)[1]
            for j in 1:size(datacube)[2]
                if mask[i, j] == 1
                    new_matrix[i, j, :] = f(datacube[i, j, :])
                else 
                    new_matrix[i, j, :] = datacube[i, j, :]
                end
            end
        end
        return new_matrix
    end
end
function cross_apply(f, datacube, mask = ones(size(datacube)[1], size(datacube)[2]))
    """
    Takes the 2d matrix for every point in time and applies a function on it. It can be used for background_mask.jl,
    median_filter.jl etc. 
    """
    if ndims(f(datacube[:, :, 1])) == 2
        new_matrix = Array{Float32}(undef, size(datacube, 1), size(datacube, 2),size(datacube)[3])
        for i in 1:size(datacube)[3]
            new_matrix[:, :, i] = f(datacube[:, :, i])
        end    
        return new_matrix
    else 
        array = []
        for i in 1:size(datacube)[3]
            push!(array, f(datacube[:, :, i]))
        end
        return array
    end
end

function apply_mask(datacube::VectorOfArray{Any,3,Array{Any,1}}, mask = ones(Float16, (size(datacube)[1], size(datacube)[2])))
    masked_datacube = copy(datacube)
    for i in 1:size(datacube)[3]
        masked_datacube[i] = datacube[i] .* mask
    end
    return masked_datacube
end

function apply_mask(datacube::Array{Any,3}, mask = ones(Float16, (size(datacube)[1], size(datacube)[2])))
    masked_datacube = copy(datacube)
    for i in 1:size(datacube)[3]
        masked_datacube[:, :, i] = datacube[:, :, i] .* mask
    end
    return masked_datacube
end

