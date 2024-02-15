#a simple local search, will try 'n' random mutations, will return the best candidate solution found
function local_search(pieces, cloth_width, mutate_function, U_f, n, initx = [])
    #algorithm init
    iter = 0
    pieces_count = D(pieces)
    old = (initx==[]) ? init_generation(1, pieces_count)[1] : initx
    set_positions, free_positions = convert_permutation( pieces, old, cloth_width)
    u_old = U_f(pieces, set_positions)
    u_new = 0
    # try random mutations
    while ( iter < n )
        iter = iter+1
        new_child = mutate_function(old)
        set_positions, free_positions = convert_permutation( pieces, new_child, cloth_width)
        u_new = U_f(pieces, set_positions)
        if (u_new >= u_old)
            continue
        end
        old = new_child
        u_old = u_new
    end
    # debugging purposes
    #if !is_permutation(old)
    #    println("failed ", old)
    #    exit()
    #end
    return u_old, old
end

#the same local search, just with plotting and additional output included
function local_search_documented(pieces, cloth_width, mutate_function, U_f, n, initx = [])
    iter = 0
    pieces_count = D(pieces)
    old = (initx==[]) ? init_generation(1, pieces_count)[1] : initx
    set_positions, free_positions = convert_permutation( pieces, old, cloth_width)
    u_old = U_f(pieces, set_positions)
    u_new = 0
    utils = [u_old]
    progress = [deepcopy(old)]
    while ( iter < n )
        iter = iter+1
        new_child = mutate_function(old)
        set_positions, free_positions = convert_permutation( pieces, new_child, cloth_width)
        u_new = U_f(new_child, set_positions)
        if (u_new >= u_old)
            append!(utils, u_old)
            append!(progress, deepcopy([old]) )
            continue
        end
        append!(utils, u_new)
        append!(progress, deepcopy([new_child]) )
        old = new_child
        u_old = u_new
    end
    return u_old, old, utils, progress
end

function local_search_rotations(pieces, cloth_width, mutate_function, U_f, n, initx = [])
    #algorithm init
    iter = 0
    pieces_count = D(pieces)
    old = (initx==[]) ? init_generation_rotations(1, pieces_count)[1] : initx
    set_positions, free_positions = convert_permutation_rotations( pieces, old, cloth_width)
    u_old = U_f(pieces, set_positions)
    u_new = 0
    #try random mutations
    while ( iter < n )
        iter = iter+1
        new_child = mutate_function(old)
        set_positions, free_positions = convert_permutation_rotations( pieces, new_child, cloth_width)
        u_new = U_f(pieces, set_positions)
        if (u_new >= u_old)
            continue
        end
        old = new_child
        u_old = u_new
    end
    return u_old, old
end

function local_search_rotations_documented(pieces, cloth_width, mutate_function, U_f, n, initx = [])
    iter = 0
    pieces_count = D(pieces)
    old = (initx==[]) ? init_generation_rotations(1, pieces_count)[1] : initx
    set_positions, free_positions = convert_permutation_rotations( pieces, old, cloth_width)
    u_old = U_f(pieces, set_positions)
    u_new = 0
    utils = [u_old]
    progress = [deepcopy(old)]
    while ( iter < n )
        iter = iter+1
        new_child = mutate_function(old)
        set_positions, free_positions = convert_permutation_rotations( pieces, new_child, cloth_width)
        u_new = U_f(pieces, set_positions)
        if (u_new >= u_old)
            if mod(iter, 500) == 1
                append!(utils, u_old)
                append!(progress, deepcopy([old]) )
            end
            continue
        end
        if mod(iter, 500) == 1
            append!(utils, u_new)
            append!(progress, deepcopy([new_child]) )
        end

        old = new_child
        u_old = u_new
    end
    return u_old, old, utils, progress
end