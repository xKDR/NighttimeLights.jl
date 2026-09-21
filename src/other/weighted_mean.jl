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
    return sum(Float64.(n) .* w) / s # Float64 so that a Float16 cube cannot overflow on the way up
end
