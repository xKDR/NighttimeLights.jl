"""
Applies a function to each timeseries of a datacube present in a mask. 
# Example:
```
julia> datacube = rand(1:10.0, 10,10,10)
julia> mask = rand(0:1, 10, 10)
julia> long_apply(sum, datacube)
```    
"""
function long_apply(f, datacube::Array, mask = ones(size(datacube)[1], size(datacube)[2]))
    if ndims(f(datacube[1, 1, :])) ==0
        new_matrix = Array{Union{Missing, Float16}, 3}(undef, size(datacube, 1), size(datacube, 2))
        for i in 1:size(datacube)[1]
            for j in 1:size(datacube)[2]
                new_matrix[i, j] = f(datacube[i, j, :])
            end
        end
        return new_matrix
    else    
        new_matrix = Array{Union{Missing, Float16}}(undef, size(datacube, 1), size(datacube, 2),size(datacube)[3])
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
"""
Applies a function to each cross section of a datacube present. 
# Example:
```
julia> datacube = rand(1:10.0, 10,10,10)
julia> mask = rand(0:1, 10, 10)
julia> long_apply(sum, datacube)
```    
"""
function cross_apply(f, datacube, mask = ones(size(datacube)[1], size(datacube)[2]))
    if ndims(f(datacube[:, :, 1])) == 2
        new_matrix = Array{Union{Missing, Float16}}(undef, size(datacube, 1), size(datacube, 2),size(datacube)[3])
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


    