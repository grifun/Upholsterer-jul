# an evolution process
function evolution(pieces, cloth_width, can_rotate, U_f, population_size, n) 
    #0. init evolution
    println("initializing evolution")
    population = init_generation_rotations(population_size, D(pieces) )
    best_utils = []
    utils = Vector{Float64}(undef,population_size)
    compute_utils(pieces, cloth_width, can_rotate, U_f, population, utils)

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
        compute_utils(pieces, cloth_width, can_rotate, U_f, children, children_utils)

    #3. mutate
        println("mutating")
        mutated_children = mutate(can_rotate, children)
        mutated_children_utils = Vector{Float64}(undef,ceil(Int,population_size/2))
        compute_utils(pieces, cloth_width, can_rotate, U_f, mutated_children, mutated_children_utils)

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
        push!(best_utils, temp_best[1])
        println("in generation ", iter, "best solution found has utility ", temp_best[1] )
    end

#return the BEST solution
best = findmin(utils)
return best[1], pieces, population[best[2]], best_utils
end