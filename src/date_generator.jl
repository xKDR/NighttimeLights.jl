function date_generator(startyear, startmonth,n=95)

date = Date(startyear, startmonth) ## Year is irrelevant here as the x-axis of 
var = []
for i in 1:n
    push!(var, Dates.format(date, "u-yy"))
    date = date + Dates.Month(1)
end
return var
end