@testset "testing counter_nan" begin
    for i in 1:10
        x = rand(10:30)
        rad = rand(20:100.0, x)
        nans = unique(rand(1:x,rand(1:x)))
        for j in nans
            rad[j] = NaN
        end
        @test NighttimeLights.counter_nan(rad) == length(nans)
    end
end

@testset "testing max_nan" begin
    for i in 1:10
        x = rand(10:30)
        rad = rand(20:100.0, x)
        max = findmax(rad)
        nans = rand(1:20)
        for j in 1:nans
            nan_index = rand(1:x)
            if nan_index == max[2]
                continue
            else
                rad[nan_index] = NaN
            end
        end
        @test NighttimeLights.max_nan(rad) == max[1]
    end
end