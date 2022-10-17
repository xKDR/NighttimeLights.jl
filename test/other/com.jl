using Rasters
load_example()
img = view(radiance_datacube, Ti(1))
cog = centre_of_mass(img)

@test cog ≈ [72.9125001033, 19.120832886299997]

