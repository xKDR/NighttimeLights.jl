
# Basics of nighttime lights data

NOAA provides tif files of the nightlights images. Images in the package are represented as 2D arrays with floating-point values. Images of different months are stacked together to form 3D arrays. In this package, such 3D arrays are called datacubes. The following examples demonstrate how array indices work in Julia in the context of this package. 


```julia
image[1, 2]
```
Returns the value of the image at location [1, 2]. 1st row and 2nd column. 
```julia
datacube[:, :, 3]
```
Returns the image of the 3rd month.
```julia
datacube[1, 2, :]
```
Returns the time series values of the pixel at location [1, 2]. 
```julia
datacube[1, 2, 3]
```
Returns the value of the image at location [1, 2] of the 3rd month. 

# Loading and saving files

Images and datacubes can be be loaded and saved using the following functions. 

```@docs
load_img(filepath)
save_img(filepath, image)
load_datacube(filepath)
make_datacube(folder_path)
save_datacube(filepath, datacube)
```

# Mapping between earth and arrays

Suppose you want to find which location has the maximum value of light in an image. You can use the findmax function in julia.

```julia
findmax(my_image)
```
Suppose, the answer is [2000, 3000]. If you want to find the coordinates of this location, you'll need a mapping between the earth's coordinates and the image's indices. 

Similarly, if you were given a pair of latitude and longitude, for example, (19.05, 73.01), and you need to find the radiance of that coordinate (approximately), you'll need to convert these number to your image's indices. 

```@docs
CoordinateSystem
lat_to_row(geometry::CoordinateSystem, x)
long_to_column(geometry::CoordinateSystem, x)
row_to_lat(geometry::CoordinateSystem, x)
column_to_long(geometry::CoordinateSystem, x)
coordinate_to_image(geometry::CoordinateSystem, x::Coordinate)
image_to_coordinate(geometry::CoordinateSystem, x)
```

# Masks

Masks are 2D arrays consisting of 0s and 1s. The 1s determine the region of interest. The pixels with the value of 1 are referred to as lit and the ones with the value of 0 are referred to as dark. Masks are useful because they can be easily combined with one another.  

 To demonstrate the concept of mask, here are 3 examples:

1.  If the region of interest is India, the points inside the boundary of India will be 1, while the remaining will be 0.  
2.  If all pixels in an image below a threshold are considered background noise, such pixels can be marked as zero and the remaining can be marked as 1 to produce a background noise mask. For following code demonstrates this example. 
```julia
image = rand(0:10.0, 10, 10)
noise_threshold = function(x, threshold)
    if x < threshold
        return 0
    else 
        return 1
    end
end
threshold = 0.3
mask_mask = noise_threshold.(x, threshold) 
```
3. The standard deviation of each pixel in a datacube can be computed. Suppose those pixels with standard deviation greater than a threshold are considered outliers. In a 2D array, these pixels can be marked as 0 and the remaining can be marked as 1 to generate an outlier mask. 
```julia
datacube = rand(0:10.0, 10, 10, 10)
mask = zeros(10, 10)
std_threshold = 1
for i in 1:10
    for j in 1:10
        if std(datacube[i, j, :]) > std_threshold
            mask[i, j] = 1
        end
    end
end
```

If you multiply (elementwise) the 3 masks, you get a mask that represents the pixels above the threshold, which are inside India and which are not outliers. 

To find the number of pixels in a mask, one simply needs to do: 
```julia
sum(mask)
```
To find the area of the mask, the mask_area function of the package can be used. 
```@docs
mask_area(geometry::CoordinateSystem, mask)
```

An image can be multiplied with a mask (elementwise) so that only the pixels lit in the mask are lit in the images. For example: 
```julia
image .* noise_mask
```
Returns as image with 0s wherever there is background noise and the remaining values are the same as the original image. 

### Aggregating over masks 

While using nighttime lights, you may need to find the total lit of an image over a mask.  

For example, if you have a background noise mask (where pixels considered noise are marked as 0 and the remaining at marked as 1), you may need to find the the total of an image over the lit pixels of the mask. 

```@docs
aggregate(image, mask)
```

The aggregate function is equivalent to 
```julia
sum(image .* mask)
```
```@docs
aggregate_timeseries(datacube, mask)
```
