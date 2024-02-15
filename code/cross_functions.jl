#generates a new candidate solution from x1 and x2 by generating a random index
#everything before index is taken from x1, else is taken from x2, then corrected for valid permutation
function X_onepoint(x1, x2)
    #breed the two
    n = D(x1)
    idx = rand((1:n))
    ret = deepcopy(x1)
    ret[idx+1:n] = x2[idx+1:n]
    #fix the permutation
    #1. get missing pieces and duplicates:
    present_values = unique(ret)
    if (D(present_values) == n)
        return ret
    end
    missing = shuffle( setdiff( 1:n , present_values ) )
    #2. correct the permutation
    missing_fix_idx = 1
    for val in present_values
        duplicates = findall(x->x==val, ret)
        if D(duplicates) < 2 #means there is only 1 occurence, hence no duplicates and nothing to fix
            continue
        end
        ret[duplicates[2]] = missing[missing_fix_idx]
        missing_fix_idx += 1
        if missing_fix_idx > D(missing)
            return ret
        end
    end
    return ret
end

#generates a new candidate solution from x1 and x2 by generating a table of neighbouring pieces
#from this table, new candidate solution is constructed
function X_edgerecomb(x1, x2)
    #create table of possible neighbours
    piece_count = D(x1)
    table = Vector{Vector{Int}}(undef,piece_count)
    for i in 1:piece_count
        table[i] = fill(-1, piece_count)#Vector{Int}(4)
    end
    table[x1[1]][1] = x1[2]
    table[x1[1]][piece_count] = x1[end]
    table[x2[1]][1] = x2[2]
    table[x2[1]][piece_count] = x2[end]
    for i in 2:(piece_count)-1
        table[x1[i]][i] = x1[i-1]
        table[x2[i]][i] = x2[i-1]
        table[x1[i]][1+piece_count-i] = x1[i+1]
        table[x2[i]][1+piece_count-i] = x2[i+1]
    end
    table[x1[piece_count]][1] = x1[piece_count-1]
    table[x1[piece_count]][piece_count] = x1[1]
    table[x2[piece_count]][1] = x2[piece_count-1]
    table[x2[piece_count]][piece_count] = x2[1]
    for i in 1:piece_count
        table[i] = setdiff( table[i], [-1] )
        table[i] = shuffle( unique(table[i]) )
    end
    #construct new candidate solution
    ret = Vector{Int}(undef, piece_count)
    pieces_to_fill = shuffle( 1:piece_count )
    #randomly choose a starting piece
    piece = rand(pieces_to_fill)
    ret[1] = piece
    #remove it from the set of pieces yet to be added & from the table
    pieces_to_fill = setdiff( pieces_to_fill, [piece] )
    for i in 1:piece_count
        table[i] = setdiff( table[i] , [piece] )
    end
    #iterate this method by choosing neighbouring pieces
    filled = 2
    while filled <= piece_count
        if D(table[piece]) == 0
            piece = rand(pieces_to_fill)
        else
            piece = rand(table[piece])
        end
        pieces_to_fill = setdiff( pieces_to_fill, [piece] )
        ret[filled] = piece
        for i in 1:piece_count
            table[i] = setdiff( table[i] , [piece] )
        end
        filled += 1
    end
    return ret
end
