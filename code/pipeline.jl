
# initialize population, 15 % heuristically, rest randomly
function init_population(pieces, population_size, can_rotate)
    pieces_count = D(pieces)
    heuristed_count = ceil(Int, population_size*0.15)
    random_count = population_size - heuristed_count
    heuristed_population = []
    random_population = []
    if can_rotate
        heuristed_population = init_generation_heuristic_rotations(pieces, heuristed_count, pieces_count)
        random_population = init_generation_rotations(random_count, pieces_count)
    else
        heuristed_population = init_generation_heuristic(pieces, heuristed_count, pieces_count)
        random_population = init_generation(random_count, pieces_count)
    end
    population = append!(heuristed_population, random_population)
    return population
end


# a helper function with parallelization
function run_local_search(pieces, cloth_width, can_rotate, U_f,  X, U)
    population_size = D(X)
    if can_rotate
        Threads.@threads for i in 1:population_size
            U[i], X[i] = local_search_rotations(pieces, cloth_width, M_rotate_subset_and_swap_2, U_f, LOCAL_SEARCH_ITERATIONS, deepcopy(X[i]))
        end
    else
        Threads.@threads for i in 1:population_size
            U[i], X[i] = local_search(pieces, cloth_width, M_push_one, U_f, LOCAL_SEARCH_ITERATIONS, deepcopy(X[i]))
        end
    end
end

# a helper function with parallelization
function compute_utils(pieces, cloth_width, can_rotate, U_f, X, U)
    population_size = D(X)
    if can_rotate
        Threads.@threads for i in 1:population_size
            set_positions, free_positions = convert_permutation_rotations( pieces, X[i], cloth_width)
            U[i] = U_f(pieces, set_positions)
        end
    else
        Threads.@threads for i in 1:population_size
            set_positions, free_positions = convert_permutation( pieces, X[i], cloth_width)
            U[i] = U_f(pieces, set_positions)
        end
    end
end

# a helper function with parallelization
function select_parents(pieces, cloth_width, X, U)
    population_size = D(X)
    parent_pairs = [[] for a in 1:ceil(Int, population_size/2)]
    Threads.@threads for i in 1:ceil(Int,population_size/2)
        parent_pairs[i] = S_tournament(X, U, 2, pieces)
    end
    return parent_pairs
end

# a helper function with parallelization
function create_children(pieces, parent_pairs, can_rotate)
    population_size = D(parent_pairs)
    children = [[] for a in 1:ceil(Int, population_size)]
    if can_rotate
        Threads.@threads for i in 1:ceil(Int,population_size)
            new_permutation = X_onepoint(parent_pairs[i][1][1], parent_pairs[i][2][1])
            if mod(rand(Int), 2) == 1
                new_rotation = parent_pairs[i][1][2] .& parent_pairs[i][2][2]
            else
                new_rotation = parent_pairs[i][1][2] .| parent_pairs[i][2][2]
            end
            children[i] = [new_permutation, new_rotation]
        end
    else
        Threads.@threads for i in 1:ceil(Int,population_size)
            children[i] = X_onepoint(parent_pairs[i][1], parent_pairs[i][2])
        end
    end
    return children
end

# a helper function with parallelization
function mutate(can_rotate, X)
    population_size = D(X)
    mutants = [[] for a in 1:ceil(Int, population_size)]

    Threads.@threads for i in 1:ceil(Int,population_size)
        mutants[i] = M_swap_parts(X[i])
    end
    return mutants
end
