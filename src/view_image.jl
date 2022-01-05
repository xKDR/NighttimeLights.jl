"""
Displays and image in GIMP

# Example:
view_img(rand(1:10,10,10))
"""
function view_img(img)
    save_img("/tmp/image.tif", img)
    run(`gimp /tmp/image.tif`)
end

## More will be added to this library. Missinngs can be marked with red. 
## Boundary layers can be added.