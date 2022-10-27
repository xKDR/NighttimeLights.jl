img = view(radiance_datacube, Ti(At(201204)))
res = 15
R1 = 5
R2 = 13
lat = 19.07
long = 72.87
bounds1, mask1 = annular_ring(img, R1, R2, lat, long, res) 

R = 13
bounds2, mask2 = annular_ring(img, R, lat, long, res) 

@test bounds1 == bounds2