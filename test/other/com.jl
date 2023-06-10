img = view(radiance_datacube, Ti(At(Date("2012-04"))))
cog = centre_of_mass(img)

@test cog ≈ [72.88333535640002, 19.070832885899996]

img = view(radiance_datacube, Ti(1))
spaster = sparse(Array(img)[:,:,1])
centre_of_mass(spaster, dims(img)) ≈ [72.88333535640002, 19.070832885899996]