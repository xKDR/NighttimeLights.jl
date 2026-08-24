"""
Applies a function to each timeseries of a datacube present in a mask. Pixels where the mask is `missing` are skipped; the function is applied wherever the mask has a value.
# Example:
```
julia> datacube = rand(1:10.0, 10,10,10)
julia> mask = rand([missing, 1], 10, 10)
julia> iterator(x::Vector) = x .+ 1
julia> long_apply(iterator, datacube, mask)
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
A mask can be applied to a datacube so that each image of the datacube has `missing` wherever the mask is dark (`missing`) and the original value wherever the mask is lit (1). The mask is applied by multiplication, so dark pixels are removed from the data rather than set to 0; this keeps them out of downstream statistics instead of treating them as measurements of zero radiance.
# Example:
```
datacube = rand(1:10.0, 10,10,10)
mask = rand([missing, 1], 10, 10)
apply_mask(datacube, mask)
```
"""
function apply_mask(data, mask = ones((size(data)[1], size(data)[2])))
   mask .* data
end