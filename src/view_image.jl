function view_img(img)
    save_img("/tmp/image.tif",img)
    run(`gimp /tmp/image.tif`)
end

## More will be added to this library. NaN can be marked with red. 
## Boundary layers can be added.