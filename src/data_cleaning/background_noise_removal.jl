function threshold(x,minrad=0,replacement=NaN)
    if x<=minrad
        return replacement
    else
        return x
    end
end

function threshold_datacube(datacube,minrad=0,replacement=NaN,mask=ones(Int8, (size(datacube)[1],size(datacube)[2])))
    cleaned_matrix = copy(datacube)
    for i in 1:size(cleaned_matrix)[1]
        for j in 1:size(cleaned_matrix)[2]
            for k in 1:size(cleaned_matrix)[3]
                if mask[i,j] == 1
                    cleaned_matrix[i,j,k] = threshold(cleaned_matrix[i,j,k],minrad,replacement)
                end
            end
        end
    end
    return cleaned_matrix
end

function noise_threshold(x,th = 0.4)
    if x<=th
        return 0
    else
        return 1
    end
end

function background_noise_mask(datacube=radiance_datacube, clouds=clouds_datacube, th=0.4)
    last_year      = datacube[:,:,(size(datacube)[3]-12):size(datacube)[3]]
    cloudYear   = clouds[:,:,(size(datacube)[3]-12):size(datacube)[3]]
    average_lastyear = copy(datacube[:,:,1])
    for i in 1:size(last_year)[1]
        for j in 1:size(last_year)[2]
            average_lastyear[i,j] = weighted_mean(last_year[i,j,:],cloudYear[i,j,:])
        end
    end
    mask = noise_mask.(average_lastyear,th)
    return mask
end