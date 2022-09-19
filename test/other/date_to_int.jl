dates = collect(Date(2012,4):Month(1):Date(2022, 06))
timestamps = NighttimeLights.yearmon.(dates)

@test length(timestamps) == length(dates)