function reduce_resolution(A, row_divider, column_divider)
    new_rows = size(A)/row_divider
    new_columns = size(A)/column_divider
    B = mean(mean(reshape(A, row_divider, column_divider, new_rows, new_columns), dims = 1), dims = 2)
    reshape(B, new_rows, new_columns)
end