# checks overlap of rectangles by their sides
function overlap(position1, piece1, position2, piece2)
    ld1 = position1
    ru1 = position1 .+ piece1

    ld2 = position2
    ru2 = position2 .+ piece2

    if ld1[1] >= ru2[1] || ld2[1] > ru1[1]
        return false
    end

    if ru1[2] < ld2[2] || ru2[2] < ld1[2]
        return false
    end
    
    return true
end

# checks if a piece can fit to the specific place (that is it does not overlap any other piece)
function will_fit_to_place(place, piece, set_positions, pieces, cloth_width)
    #1. check height is enough
    max_height = place[2] + piece[2]
    if max_height > cloth_width
        return false
    end
    
    #2 check it does not overlap any other piece
    for pos_struct in set_positions
        item = pos_struct[1]
        pos = pos_struct[2]
        if overlap(place, piece, pos, item)
            return false
        end
    end
    return true
end

# is there a place this piece will fit, or will it require new one completely
function fit_somewhere(free_positions, set_positions, piece, pieces, cloth_width)
    for place in free_positions
        succ = will_fit_to_place(place, piece, set_positions, pieces, cloth_width)
        if succ
            return place
        end
    end
    return "ERROR FITTING THE PLACE"
end

# after placing a piece, locate possible new positions for future placement
function add_new_position( positions, add_pos )
    n = D(positions)
    new_positions = []
    i = 1
    while i <= n
        pos = positions[i]
        if pos[1] <= add_pos[1]
            new_positions = append!(new_positions, [pos] )
        else
            break
        end
        i = i+1
    end
    new_positions = append!(new_positions, [add_pos] )
    while i <= n
        pos = positions[i]
        new_positions = append!(new_positions, [pos] )
        i = i+1
    end
    return new_positions
end

# 
function update_positions(old_positions, new_position, set_positions, piece, pieces, cloth_width)
    #1 remove the old free position
    positions = setdiff(old_positions, [new_position])

    #2 add new free positions
    if new_position[2] == 0                                         #adding to the bottom
        if piece[2] == cloth_width
            add_pos = [ new_position[1] + piece[1], 0 ]             #new spot at the bottom
            positions = append!(positions, [add_pos] )
        else
            add_pos1 = [ new_position[1] + piece[1], 0 ]            #new spot at the bottom
            add_pos2 = [ new_position[1], piece[2] ]
            positions = append!(positions, [add_pos2])
            positions = append!(positions, [add_pos1])
        end
    else                                                            #adding somewhere else
        if new_position[2] + piece[2] == cloth_width                #fills the width
            add_pos1 = [ new_position[1] + piece[1], new_position[2] ]
            positions = add_new_position( positions, add_pos1 )
            add_pos2 = [ total_length(pieces,set_positions), 0 ]
            positions = add_new_position( positions, add_pos2 )
        else
            add_pos1 = [ new_position[1] + piece[1], new_position[2] ]      #new spot at the bottom
            add_pos2 = [ new_position[1], new_position[2] + piece[2] ]
            
            positions = add_new_position( positions, add_pos2 )
            positions = add_new_position( positions, add_pos1 )

            add_pos3 = [ total_length(pieces,set_positions), 0 ]
            positions = add_new_position( positions, add_pos3 )
        end

    end
end

# makes a specific list of pieces and their locations from a permutation
function convert_permutation(pieces, permutation, cloth_width)
    free_positions = [[0,0]]
    set_positions = []

    for index in permutation
        piece = pieces[index]
        
        new_position = fit_somewhere( free_positions, set_positions, piece, pieces, cloth_width )
        set_positions = append!( set_positions, [[ [piece[1], piece[2]], new_position]] )
        free_positions = update_positions( free_positions, new_position, set_positions, piece, pieces, cloth_width )
    end
    return set_positions, free_positions
end

# makes a specific list of pieces and their locations from a permutation
function convert_permutation_rotations(pieces, individual, cloth_width)
    free_positions = [[0,0]]
    set_positions = []

    indexes = individual[1]
    rotations = individual[2]

    for i in 1:D(pieces)
        index = indexes[i]
        rotated = rotations[i]
        piece = deepcopy(pieces[index])
        if rotated > 0
            piece[1], piece[2] = piece[2], piece[1]
        end
        new_position = fit_somewhere( free_positions, set_positions, piece, pieces, cloth_width )
        set_positions = append!( set_positions, [[ [piece[1], piece[2]], new_position]] )
        free_positions = update_positions( free_positions, new_position, set_positions, piece, pieces, cloth_width )
    end
    return set_positions, free_positions
end


# computes the total used length
function total_length(pieces, positions)
    item_count = D(positions)
    max_x = 0
    for i in 1:item_count
        pos_struct = positions[i]
        position = pos_struct[2]
        piece = pos_struct[1]
        far_x = position[1] + piece[1]
        if far_x > max_x
            max_x = far_x
        end
    end
    return max_x
end

# computes the amount of individual cuts required
function cutlines(pieces, positions)
    item_count = D(positions)
    x_lines = []
    y_lines = []
    for i in 1:item_count
        pos_struct = positions[i]
        position = pos_struct[2]
        piece = pos_struct[1]
        x_line1 = position[2]
        x_line2 = position[2] + piece[2]
        y_line1 = position[1]
        y_line2 = position[1] + piece[1]
        if !(x_line1 in x_lines)
            x_lines = append!(x_lines, [x_line1])
        end 
        if !(x_line2 in x_lines)
            x_lines = append!(x_lines, [x_line2])
        end 
        if !(y_line1 in y_lines)
            y_lines = append!(y_lines, [y_line1])
        end 
        if !(y_line2 in y_lines)
            y_lines = append!(y_lines, [y_line2])
        end 
    end
    return D(x_lines) + D(y_lines)
end


# computes the quasi-manhattan distance of 2 squares
function rect_distance(piece1, position1, piece2, position2) 
    if position1 == position2      #the same item
        return 0
    end

    ld1 = position1
    rd1 = position1 .+ [piece1[1], 0]
    lu1 = position1 .+ [0, piece1[2]]
    ru1 = position1 .+ piece1

    ld2 = position2
    rd2 = position2 .+ [piece2[1], 0]
    lu2 = position2 .+ [0, piece2[2]]
    ru2 = position2 .+ piece2

    return minimum( abs.( [ld1[1] - rd2[1], rd1[1] - ld2[1] ] ) )
end

# computes the distances of identical pieces
function neighbouring(pieces, positions)
    total_distance = 0
    item_count = D(positions)
    for i1 in 1:item_count-1
        pos_struct1 = positions[i1]
        position1 = pos_struct1[2]
        piece1 = pos_struct1[1]
        for i2 in (i1+1):item_count
            pos_struct2 = positions[i2]
            position2 = pos_struct2[2]
            piece2 = pos_struct2[1]

            if piece1 == piece2
                total_distance += rect_distance(piece1, position1, piece2, position2)
            end
        end

    end
    return total_distance
end

function summed_loss(pieces, positions)
    return total_length(pieces, positions) + cutlines(pieces, positions) + 0.1*neighbouring(pieces, positions)
end