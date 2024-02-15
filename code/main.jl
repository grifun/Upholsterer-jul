include("memetic.jl")
include("loss.jl")
include("util.jl")
include("init.jl")
include("mutate_functions.jl")
include("cross_functions.jl")
include("selection_functions.jl")
include("local_search.jl")
include("pipeline.jl")
include("benchmark.jl")
include("evolution.jl")

println("Welcome to Tomas Kasl's solution to EOA semestral project")
println("Loading libraries...")

using Printf
using Random
using Luxor
using Distributions
#using Interact #required for the UI
#using Blink

TOURNAMENT_SIZE = 4
LOCAL_SEARCH_ITERATIONS = 100
RUNS = 10 #for benchmarks
BENCH = false
#BENCH = true

# a relic, a prove I tried to make the Julia UI work
function show_ui()
    label_0 = "Planovac strihu latky"
    
    label_1 = "Sirka latky"
    input_1 = Interact.textbox(hint="v cm"; value="0");
    line_1 = hbox(label_1, input_1)
    
    label_2 = "Zalezi na orientaci"
    input_2 = Interact.textbox(hint="ano?"; value="ano");
    line_2 = hbox(label_2, input_2)


    label_3 = "Zadej pozadovane kusy ve tvaru (x,y),(x,y),..."
    input_3 = Interact.textbox(hint="ano?"; value="ano")
    line_3 = hbox(label_3, input_3)

    start_button = button("Šup!")

    ui = vbox(label_0, vline(), line_1, vline(), line_2, vline(), line_3, vline(), start_button)

    w = Window()
    body!(w, ui);
    
    handle(w, "press") do 
        println("pressed")
    end
    readline()
end

# loads the definition from a text file
# pattern:
# # output filename
# # roll width
# # can rotate
# # x_i y_i 
function read_problem(filename)
    cloth_width = 0
    can_rotate = false
    items = []
    labels = []
    last_label = 1
    item_count = 0
    picname = "trycatch.png"
    open(filename) do f
        line = 0
        s = readline(f)
        picname = s

        s = readline(f)
        cloth_width = parse(Int64, s)

        s = readline(f)
        can_rotate = parse(Bool, lowercase(s))

        while !eof(f)
            s = readline(f)
            ss = rsplit(s)
            x = parse(Int64, ss[1])
            y = parse(Int64, ss[2])
            items = append!(items, [[x,y]])
            item_count += 1
            if item_count > 1
                
                if items[item_count] != items[item_count-1]
                    last_label += 1
                end 
            end
            labels = append!(labels, last_label)
        end
    end
    return cloth_width, can_rotate, items, labels, picname
end

# writes a line to a file, used for communication with UI
function write_status(string, filename)
    touch(filename)
    open(filename, "w") do f
        write(f, string)
    end
end

# plots the found solution, requires sizes and positions of all pieces
function plot_cloth(cloth_width, pieces, positions, labels, total_len, picname)
    item_count = D(pieces)
    my_x = -total_len/2
    my_y = -cloth_width/2
    @png begin
        
        sethue("black")
        println("drawing:")
        rect(my_x, my_y, total_len+20, cloth_width, :stroke)

        sethue("red")
        for i in 1:item_count
            sethue("red")
            pos_struct = positions[i]
            position = pos_struct[2]
            piece = pos_struct[1]
            x = my_x+position[1]
            y = -(my_y+position[2])
            rect(x, y, piece[1], -piece[2], :fill)
            sethue("black")
            rect(x, y, piece[1], -piece[2], :stroke)
            my_text = string(piece[1])*"x"*string(piece[2])
            fontsize(9)
            Luxor.text(my_text, Point( x+15, y-5), halign=:center, valign=:middle)
            x = my_x+position[1] + (piece[1]/2)
            y = -(my_y+position[2]+piece[2]/2)
            fontsize(12)
            Luxor.text(string(labels[i]), Point( x, y), halign=:center, valign=:middle)
        end
        fontsize(15)
        Luxor.text(string(total_len)*" cm", Point( 0, cloth_width/2+10), halign=:center, valign=:middle)
    end 100+total_len cloth_width+50 picname
end

# since presolving (and other routines) change the order of labels for plotting, we need to recalculate them
function recalculate_labels(new_pieces, og_pieces, og_labels)
    new_labels = zeros(Int, D(og_labels))
    n = D(og_pieces)
    for i in 1:n
        piece = new_pieces[i]
        for i2 in 1:n
            piece2 = og_pieces[i2]
            if piece == piece2 || ( [piece[2], piece[1]] == [piece2[1], piece2[2]] )
                new_labels[i] = og_labels[i2]
                break
            end
        end
    end
    return new_labels
end

function test_local_search()
    loss, permutation = local_search(pieces4, cloth_width, M_push_one, summed_loss, 1000)
    set_positions, free_positions = convert_permutation( pieces4, permutation, cloth_width )
    plot_cloth(cloth_width, pieces4, set_positions, ones(Int, D(pieces4)), total_length(pieces4, set_positions), picname)
end

#show_ui()
#test_local_search()
#exit()

if BENCH
    lc_utils = benchmark_local_search(pieces, cloth_width, 10000)
    ea_utils = benchmark_ea(pieces, cloth_width, 20)
    meme_utils = benchmark_meme(pieces, cloth_width, 20)

    println(size(lc_utils))
    println(lc_utils)
    println(size(ea_utils))
    println(ea_utils)
    println(size(meme_utils))
    println(meme_utils)

    plot_utils_progress(1:20,[lc_utils, ea_utils, meme_utils], "Agregated loss function")
    exit()
end 
cloth_width, can_rotate, pieces, labels, picname = read_problem("code/problem.txt")

if can_rotate
    loss, new_pieces, output = memetic(pieces, cloth_width, true, summed_loss, 250, 20)
    permutation = output[1]
    rotation = output[2]
    set_positions, free_positions = convert_permutation_rotations( new_pieces, output, cloth_width )
    plot_cloth(cloth_width, pieces, set_positions, recalculate_labels(new_pieces, pieces, labels)[permutation], total_length(pieces, set_positions), picname)
else
    loss, new_pieces, permutation = memetic(pieces, cloth_width, false, summed_loss, 150, 20)
    set_positions, free_positions = convert_permutation( new_pieces, permutation, cloth_width )
    plot_cloth(cloth_width, pieces, set_positions, recalculate_labels(new_pieces, pieces, labels)[permutation], total_length(pieces, set_positions), picname)
end


write_status("done", "code/status.txt")
