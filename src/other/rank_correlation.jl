function t_test(n,r)
    stat = r *sqrt((n-2)/1-r^2)
    t_dist = TDist(n-2)
    return pvalue(t_dist,stat,tail=:right)
end 

function rank_correlation_test(radiance, clouds)
    nans = findall(isnan, radiance)
    y = filter!(!isnan, copy(radiance))
    x = convert(Array{Float64}, copy(clouds))
    x[nans] .= NaN
    x = filter!(!isnan, x)
    y_de = detrend_ts(y)
    r = corspearman(y_de, x)
    n = length(y_de)
    return t_test(n,r)
end