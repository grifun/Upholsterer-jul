#for a given set of pieces, a generation of size 'population_size' will be randomly generated
function init_generation(population_size, n)
    X = [[] for a in 1:population_size]
    Threads.@threads for i in 1:population_size
        X[i] = shuffle(1:n)
    end
    return X
end

#for a given set of pieces, a generation of size 'population_size' will be randomly generated
function init_generation_rotations(population_size, n)
    X = [[] for a in 1:population_size]
    Threads.@threads for i in 1:population_size
        X[i] = [shuffle(1:n ), zeros(Int,n)] 
    end
    return X
end

# return an individual - a permutation sorted by height
function heuristic_generation(pieces)
    sizes = []
    for piece in pieces
        sizes = append!(sizes, [piece[2]])
    end
    return reverse( sortperm(sizes) )
end

# return a population of permutations sorted by height
function init_generation_heuristic(pieces, population_size, n)
    X = []
    x = heuristic_generation(pieces)
    for i in 1:population_size
        append!( X, [deepcopy(x)]  )
    end
    return X
end

function init_generation_heuristic_rotations(pieces, population_size, n)
    X = []
    x = heuristic_generation(pieces)
    for i in 1:population_size
        append!( X, [[deepcopy(x), zeros(Int,n)] ] )
    end
    return X
end