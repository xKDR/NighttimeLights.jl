function weighted_mean(numbers,weights)
    wm = 0
    for i in 1:length(numbers)
        wm = wm + numbers[i]*weights[i]
    end
    return wm/sum(weights)
end
