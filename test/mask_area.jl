@testset "mask_area" begin
    for i in 1:5
        mask = rand(0:1, 156, 85)
        @test mask_area(MUMBAI_COORDINATE_SYSTEM, mask) >= 0 
    end
    for i in 1:5
        mask = zeros(156, 85)
        @test mask_area(MUMBAI_COORDINATE_SYSTEM, mask) == 0 
    end
end
