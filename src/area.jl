## Using cubic spline model to define earth's curvature. 
## Data points are obtained from: https://www.ngdc.noaa.gov/mgg/topo/report/s6/s6A.html

global LAT =[-90.0, -89, -86, -82, -78, -74, -70, -60, -50, -40, -30, -20, -10, 0, 10, 20, 30, 40, 50, 60, 70, 74, 78, 82, 86, 89, 90]
global EW  =[0, 16.0, 64, 133, 193, 256, 318, 465, 598, 712, 804, 872, 914, 928, 914, 872, 804, 712, 598, 465, 318, 256, 193, 133, 64, 16, 0]/1000
global NS  =[931, 931.0, 931, 931, 930, 930, 930, 929, 927, 925, 924, 923, 922, 921, 922, 923, 924, 925, 927, 929, 930, 930, 930, 931, 931,931, 931]/1000 # We divide by thousand to convert into kilometer from meter
global EW = EW / 2 # The values are for 30", our geometry is 15"
global NS = NS / 2 

global MODEL_EW = CubicSpline(LAT, EW)
global MODEL_NS = CubicSpline(LAT, NS)

"""
The area of each pixel is added to determine the total area of a mask. 
```
mask = rand(0:1,8000,7100) 
mask_area(INDIA_COORDINATE_SYSTEM, mask) 
```
"""
function mask_area(geometry::CoordinateSystem, mask)
    area = 0 
    for i in 1:geometry.height
        for j in 1:geometry.width
            if mask[i, j] ==1 
                lat = row_to_lat(geometry, i)
                ns = MODEL_NS[lat]
                ew = MODEL_EW[lat]
                area = area + ew * ns
            end
        end
    end
    return area
end
