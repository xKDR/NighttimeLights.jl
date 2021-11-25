function mask_vals(img,mask=ones(Float16, (size(img)[1],size(img)[2])))
    vals = []
    for i in 1:size(img)[1]
        for j in 1:size(img)[2]
            if mask[i,j] == 1 
                push!(vals,img[i,j])
            end
        end
    end
    return vals
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
    #use multiple dispatch here
    if ndims(data) == 2
        return data .* mask
    end
    if typeof(data) == VectorOfArray{Any,3,Array{Any,1}}
        for i in 1:length(data)
            data[i] = data[i] .* mask
        end
        return data
    end
    masked_data = copy(data)
    for i in 1:size(data)[3]
        masked_data[:, :, i] = data[:, :, i] .* mask
    end
    return masked_data
end

add_masks = function(mask1, mask2)
    mask_sum =  BitArray(zeros(size(mask1)[1], size(mask2[2])))
    mask_sum           = mask1 .| BitArray(mask2)
    return sparse(Array{Int8}(mask_sum))
end