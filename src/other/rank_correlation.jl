function t_test(n, r)
    stat = r * sqrt((n - 2) / (1 - r^2))
    t_dist = TDist(n - 2)
    return pvalue(t_dist, stat, tail=:right)
end

function rank_correlation_test(radiance, ncfobs)
    y = collect(skipmissing(radiance))
    y_de = Array{Float64}(detrend_ts(y))
    x = Float64.(collect(skipmissing(ncfobs)))
    r = corspearman(y_de, x)
    n = length(y_de)
    return t_test(n, r)
end
