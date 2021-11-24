function weighted_mean(numbers, weights)
    tmp_weights = []
    tmp_number = []
    for i in 1:length(weights)
        if isnan(numbers[i])
            continue
        else
            push!(tmp_weights, weights[i])
            push!(tmp_number, numbers[i])
        end
    end
    weights = tmp_weights
    numbers = tmp_number
    if length(weights) == 0
        return 0
    end
    if sum(tmp_weights) == 0 
        return 0 # Such a pixel is background noise for us 
    end
    
    wm = 0
    for i in 1:length(tmp_number)
        wm = wm + tmp_number[i]*tmp_weights[i]
    end
    return wm/sum(tmp_weights)
end
