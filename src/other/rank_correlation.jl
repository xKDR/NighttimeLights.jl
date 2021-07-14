function rank_correlation_test(rad, cfobs)
    R"""
    options(warn=-1)
    cor_test <- function(x, y)
    {
        time         <- seq(1, by=1/12, length.out = length(x)) # capturing time trend
        m            <- lm(x ~ time, na.action = na.exclude)
        x_           <- residuals(m) #removing time trend
        ot           <- cor.test(x_, y, alternative = "greater", method = "spearman", exact = FALSE, na.action = na.omit) # one tail test
        return       <- ot$p.value
    }
    """
    return convert(Float16,convert(Array{Float32}, rcall(:cor_test, rad, cfobs))[1])
end

# function t_test(n,r)
#     stat = r *sqrt((n-2)/1-r^2)
#     t_dist = TDist(n-2)
#     return pvalue(t_dist,stat,tail=:right)
# end 

# function rank_correlation_test(radiance, clouds)
#     radiance_de = detrend_ts(radiance)
#     r = corspearman(radiance_de, clouds)
#     n = length(radiance)
#     return t_test(n,r)
# end
