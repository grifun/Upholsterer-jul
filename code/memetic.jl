# excludes items with maximal height out of the process
function presolve(pieces, cloth_width, can_rotate)
    sorted = heuristic_generation(pieces)
    min_height = pieces[ sorted[D(pieces)] ][2]
    println("min_height ", min_height)

    set_pieces = []
    left_pieces = []
    for id in sorted
        piece = pieces[id]
        if cloth_width - piece[2] < min_height || (piece[2] <= (cloth_width/2) && cloth_width - 2*piece[2] < min_height)
            push!(set_pieces, piece)
        else
            push!(left_pieces, piece)
        end
    end
    println("presolved pieces ", set_pieces)
    println("left pieces ", left_pieces)
    return set_pieces, left_pieces
end

# includes the excluded items with maximal height bach in
function connect_solutions(presolved_pieces, solved_pieces, solved_permutation)
    solved_permutation .+= D(presolved_pieces)
    permutation = append!(collect(1:D(presolved_pieces)), solved_permutation)
    pieces = append!(presolved_pieces, solved_pieces)
    return pieces, permutation
end

function connect_solutions_rotations(presolved_pieces, solved_pieces, solved_permutation)
    solved_permutation[1] .+= D(presolved_pieces)

    permutation = append!(collect(1:D(presolved_pieces)), solved_permutation[1])
    rotation = append!( zeros(Int, D(presolved_pieces)) , solved_permutation[2] )

    pieces = append!(presolved_pieces, solved_pieces)
    return pieces, [permutation, rotation]
end

# a memetic process (EA with local search)
function memetic(pieces, cloth_width, can_rotate, U_f, population_size, n) 
    # presolve
    og_pieces = pieces
    presolved_pieces, pieces = presolve(pieces, cloth_width, can_rotate)
    if D(pieces) == 0
        return 0, presolved_pieces, collect( 1:D(presolved_pieces) )
    end
   
    #0. init evolution
    println("initializing evolution")
    population = init_population(pieces, population_size, can_rotate)
    utils = Vector{Float64}(undef,population_size)
    best_utils = []
    run_local_search(pieces, cloth_width, can_rotate, U_f, population, utils)

    iter = 0
    while (iter < n)
        iter += 1
        write_status("gen: "*string(iter)*"/"*string(n), "code/status.txt")
    #1. select parents
        println("starting generation ", iter)
        parent_pairs = select_parents(pieces, cloth_width, population, utils)

    #2. make children
        println("making children")
        children = create_children(pieces, parent_pairs, can_rotate)
        children_utils = Vector{Float64}(undef,ceil(Int,population_size/2))
        compute_utils(pieces, cloth_width, can_rotate, U_f, children[1:ceil(Int,population_size/2)], children_utils)

    #3. mutate
        println("mutating")
        mutated_children = mutate(can_rotate, children)
        mutated_children_utils = Vector{Float64}(undef,ceil(Int,population_size/2))
        run_local_search(pieces, cloth_width, can_rotate, U_f, mutated_children, mutated_children_utils)

    #4. merge
        println("merging population")
        append!( population, children, mutated_children )
        append!( utils, children_utils, mutated_children_utils )

    #5. kill-off weaklings
        println("killing off weaklings")
        util_median = median(utils)
        #get population with utility function under median
        fit_population_idx = (utils .<= util_median)
        population = (population[fit_population_idx])[1:population_size]
        utils = (utils[fit_population_idx])[1:population_size]
        temp_best = findmin(utils)
        if BENCH
            push!(best_utils, temp_best[1])
        end
        println("in generation ", iter, " best solution found has utility ", temp_best[1] )
    end

    #return the BEST solution
    best = findmin(utils)
    if BENCH
        return best[1], pieces, population[best[2]], best_utils
    end
    if can_rotate
        final_pieces, final_permutation = connect_solutions_rotations(presolved_pieces, pieces, population[best[2]])
    else
        final_pieces, final_permutation = connect_solutions(presolved_pieces, pieces, population[best[2]])
    end 
    return best[1], final_pieces, final_permutation

end