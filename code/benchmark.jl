
function benchmark_local_search(pieces, cloth_width, LC_iters)
    summed_utils = []
    for i in 1:RUNS
        println("starting LC ", i)
        u_old, old, utils, progress = local_search_rotations_documented(pieces, cloth_width, M_rotate_subset_and_swap_parts, summed_loss, LC_iters)
        if summed_utils == []
            summed_utils = utils
        else
            summed_utils .+= utils
        end
    end
    return (summed_utils ./ RUNS)[1:20]
end 


function benchmark_ea(pieces, cloth_width, EA_iters)
    summed_utils = []
    for i in 1:RUNS
        println("starting EA ", i)
        best_u, pieces, permutation, utils = evolution(pieces, cloth_width, true, summed_loss, 250, EA_iters) 
        if summed_utils == []
            summed_utils = utils
        else
            summed_utils .+= utils
        end
    end
    return summed_utils ./ RUNS
end 


function benchmark_meme(pieces, cloth_width, meme_iters)
    summed_utils = []
    for i in 1:RUNS
        println("starting MEME ", i)                
        best_u, pieces, permutation, utils = memetic(pieces, cloth_width, true, summed_loss, 10, meme_iters) 
        if summed_utils == []
            summed_utils = utils
        else
            summed_utils .+= utils
        end
    end
    return summed_utils ./ RUNS
end 


using Plots
function plot_utils_progress(xs, utils, tit)
    display(plot(xs, utils, xlabel = "Generation", ylabel = "value", title = tit, label = ["LC" "EA" "MEME"]))
    readline()
end
