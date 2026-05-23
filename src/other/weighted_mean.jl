function weighted_mean(numbers, weights)
    valid = .!ismissing.(numbers)
    if !any(valid)
        return 0
    end
    w = weights[valid]
    n = numbers[valid]
    s = sum(w)
    if s == 0
        return 0 # Such a pixel is background noise for us
    end
    return sum(n .* w) / s
end
