#a helping function
function tournament(X, U, tournament_size, pieces)
    #get 'tournament_size' random fighters
    competitor_idx = rand((1:D(X)), tournament_size)
    competitors = X[competitor_idx]
    competitors_util = U[competitor_idx]
    #select the one with maximal utility
    winner_idx = findmin(competitors_util)[2]
    return competitors[winner_idx]
end    

#return 'n' tournament winners for breeding
function S_tournament(X, U, n, pieces)
    parents = []
    for i in 1:n
        append!( parents, [tournament(X, U, TOURNAMENT_SIZE, pieces)] )
    end
    return parents
end

