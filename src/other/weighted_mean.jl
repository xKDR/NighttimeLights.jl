function weighted_mean(numbers, weights)
    if sum(weights) == 0 
        return 0 # Such a pixel is background noise for us 
    end
    tmp_weights = []
    tmp_number = []
    for i in 1:length(weights)
        if isnan(numbers[i])
            continue
        elseif weights[i] == 0
            continue
        else
            push!(tmp_weights, weights[i])
            push!(tmp_number, numbers[i])
        end
    end
    weights = tmp_weights
    numbers = tmp_number
    wm = 0
    for i in 1:length(numbers)
        wm = wm + numbers[i]*weights[i]
    end
    return wm/sum(weights)
end
