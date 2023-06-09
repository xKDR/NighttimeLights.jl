"""
Applies a function to each timeseries of a datacube present in a mask. 
# Example:
```
julia> datacube = rand(1:10.0, 10,10,10)
julia> mask = rand(0:1, 10, 10)
julia> iterator(x::Vector) = x .+ 1
julia> long_apply(x, datacube)
```    
"""
function long_apply(f, datacube, mask = ones(size(datacube)[1], size(datacube)[2]))
    for i in 1:size(datacube)[1]
        for j in 1:size(datacube)[2]
            if ismissing(mask[i, j])
                continue
            else 
                datacube[i, j, :] = f(datacube[i, j, :])
            end
        end
    end
    return datacube
end

"""
A mask can be applied to a datacube cube so that each image of the datacube has 0s wherever the mask is dark and the original value wherever the mask is lit. 
# Example:
```
datacube = rand(1:10.0, 10,10,10)
mask = rand(0:1, 10, 10)
apply_mask(datacube, mask)
```    
"""
function apply_mask(data, mask = ones((size(data)[1], size(data)[2])))
   mask .* data
end