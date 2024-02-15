#selects two random pieces within the permutation and swaps them
function M_swap2(x)
    piece_count = D(x)
    idx1 = mod(rand(Int), piece_count-1)+1
    idx2 = mod(rand(Int), piece_count-1)+1
    ret = deepcopy(x)
    ret[idx1], ret[idx2] = x[idx2], x[idx1] 
    return ret
end

#selects a random piece and swaps his position with his neighbours
function M_swap_neighbours(x)
    piece_count = D(x)
    idx1 = mod(rand(Int), piece_count-1)+1
    idx2 = mod(idx1+1, piece_count-1)+1
    ret = deepcopy(x)
    ret[idx1], ret[idx2] = x[idx2], x[idx1] 
    return ret
end

#selects two random random sections and swaps them
function M_swap_parts(x)
    piece_count = D(x)
    ret = deepcopy(x)
    idx = mod.(rand(Int, 2), piece_count-1)  .+ 1
    sort!(idx)
    idx1 = idx[1]
    idx2 = idx[2]
    max_len = min( idx2 - idx1, piece_count - idx2)
    if max_len == 0
        ret[idx1] = x[idx2]
        ret[idx2] = x[idx1]
        return ret
    end
    len = mod( rand(Int), max_len) 
    ret[ idx1:idx1+len ] = x[ idx2:idx2+len ]
    ret[ idx2:idx2+len ] = x[ idx1:idx1+len ]
    return ret
end

#changes position of one piece
function M_push_one(x)
    piece_count = D(x)
    idx = mod.(rand(Int, 2), (round(Int, piece_count))) .+ 1
    sort!(idx)
    
    ret = deepcopy(x)
    element = x[idx[2]]

    ret[idx[1]]                  = x[idx[2]]
    ret[idx[1]+1:idx[2]]         = x[idx[1]:idx[2]-1]
    ret[idx[2]+1:piece_count]    = x[idx[2]+1:piece_count]

    if !is_permutation(ret)
        println("failed ")
        println(x)
        println(ret)
        exit()
    end
    return ret
end

# randomly selects a sub_array and reverses it
function M_rotate_part(x)
    piece_count = D(x)
    idx1 = mod(rand(Int), piece_count-1)+1
    idx2 = mod(rand(Int), piece_count-1)+1
    ret = deepcopy(x)
    if idx1 > idx2
        idx1,idx2 = idx2,idx1
    end
    ret[idx1:idx2] = reverse(ret[idx1:idx2] )
    return ret
end

# with uniform distribution 0.25 , each piece has a chance to get rotated
function M_rotate_subset(rots)
    n = D(rots)
    modifier = mod.(rand(Int, n), 2) .& mod.(rand(Int, n), 2)
    new_rots = xor.(rots, modifier)
    return new_rots
end

function M_rotate_subset_and_swap_2(x)
    permutation = x[1]
    rotation = x[2]
    new_permutation = M_swap2(permutation)
    new_rotation = M_rotate_subset(rotation)
    return [new_permutation, new_rotation]
end

function M_rotate_subset_and_swap_parts(x)
    permutation = x[1]
    rotation = x[2]
    new_permutation = M_swap_parts(permutation)
    new_rotation = M_rotate_subset(rotation)
    return [new_permutation, new_rotation]
end