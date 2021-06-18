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