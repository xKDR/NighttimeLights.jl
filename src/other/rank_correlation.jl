function OtCorTest(rad, cfobs)
    R"""
    library(stringr)
    library(zoo)
    library(dplyr)
    options(warn=-1)
    CorTest <- function(x,y)
    {
        a           <- data.frame(Cleaned1 = x, CF.obs= y)
        colnames(a) <- c("Cleaned1","CF.obs")
        a$date       <- seq(as.yearmon("2012-04"), by=1/12, length.out=nrow(a))
        a$time       <- a$date - as.yearmon("2012-04")
        a$ly1        <- (a$Cleaned1)
        m            <- lm(ly1 ~ time, data=a,na.action=na.exclude)
        a$ly2        <- residuals(m) #removing time trend

        ot           = cor.test(a$CF.obs,a$ly2, alternative = "greater",method="spearman",exact=FALSE,na.action=na.omit) # one tail test
        return       <- ot$p.value
    }
    """
    """
    Does spearman onetail cor.test from R, returns the p-value.
    """
    return convert(Float16,convert(Array{Float32}, rcall(:CorTest, rad, cfobs))[1])
end

function t_test(n,r)
    stat = r *sqrt((n-2)/1-r^2)
    t_dist = TDist(n-2)
    return pvalue(t_dist,stat,tail=:right)
end 

function rank_correlation_test(radiance,clouds)
    r = corspearman(radiance,clouds)
    n = length(radiance)
    return t_test(n,r)
end
