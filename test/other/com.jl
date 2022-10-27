using SparseArrays 
img = view(radiance_datacube, Ti(1))
cog = centre_of_mass(img)

@test cog ≈ [72.9125001033, 19.120832886299997]

img = view(radiance_datacube, Ti(1))
spaster = sparse(Array(img)[:,:,1])
centre_of_mass(spaster, dims(img)) ≈ [72.9125001033, 19.120832886299997]