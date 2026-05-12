function weighted_mean(numbers, weights)
    wm = 0.0
    ws = 0.0
    for i in eachindex(numbers)
        if ismissing(numbers[i])
            continue
        end
        w = Float64(weights[i])
        wm += Float64(numbers[i]) * w
        ws += w
    end
    ws == 0.0 && return 0.0
    return wm / ws
end
