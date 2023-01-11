function read_vector(path)
    jsonbytes = read(path);
    fc = GeoJSON.read(jsonbytes)
    DataFrame(fc)
end