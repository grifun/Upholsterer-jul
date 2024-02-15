# a short array size function
D(X) = size(X)[1]

# a sanity check function
function is_permutation(x)
    if unique(x) == x
        return true
    else
        return false
    end
end

# Julia needs to get more default functions to migrate between data types
function Mat2Arr(A::AbstractMatrix)
    return [A[i, :] for i in 1:size(A,1)]
end

function Mat2Vec(A::AbstractMatrix)
    return [A[i] for i in 1:size(A,1)]
end

function Arr2Mat(A)
    return A[:,:]
end

#TEMP/TEST VALUES
cloth_width = 300
can_rotate = false
picname = "trycatch.png"

pieces1 = [[100, 120], [100, 100]]
pieces2 = [[100, 120], [100, 100], [20, 20]]
pieces3 = [[100, 120], [100, 100], [20, 20], [100, 120], [120, 30]]
pieces4 = [[100, 120], [100, 100], [20, 20], [100, 120], [120, 30], [70, 70], [70, 70], [70, 70], [70, 70], [100, 140], [140, 60],  [140, 60], [135, 135], [20, 130], [20, 130], [30, 100], [30, 100]]
