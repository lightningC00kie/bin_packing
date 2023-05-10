using Random

# define a structure for an item
struct Item
    id::Int
    size::Float64
end

# define a structure for a bin
struct Bin
    capacity::Int
    items::Vector{Item}
end

# define a function to generate random items
function generate_items(num_items, max_size)
    items = []
    for i in 1:num_items
        # items with size >= 0.5 have occur 10% of the time
        # otherwise the optimal solution is almost always the number
        # of bins it takes to fit all the items of size >= 0.5
        if rand() <= 0.1  
            item = Item(i, rand(5:10)/10)
        else
            item = Item(i, rand(1:4)/10)
        end
        # item = Item(i, rand())
        push!(items, item)
    end
    return items
end

# define a function to generate random bins
function generate_bins(num_bins, capacity)
    bins = []
    for i in 1:num_bins
        bin = Bin(capacity, [])
        push!(bins, bin)
    end
    return bins
end

# define a function to perform crossover between parents
function crossover(parent1, parent2)
    child = []
    i = 0
    while length(child) < length(parent1)
        # print("hello")
        if i == 0
            cur_parent = parent1
        else
            cur_parent = parent2
        end
        for item in chunk(cur_parent)
            # add item to child chromosome as chunks (preserving uniqueness) until child is length of parent
            if !(item in child) && length(child) < length(cur_parent)
                push!(child, item)
            # alternate between parents
            i = (i + 1) % 2
            end
        end
    end
    return child
end

# define a function to apply a mutation on a chromosome.
# subtour chunking crossover
function mutation(child)
    index1 = rand(1:length(child))
    index2 = rand(1:length(child))
    temp = child[index1]
    child[index1] = child[index2]
    child[index2] = temp
    return child
end

# define a function that returns a random chunk from a collection
function chunk(collection)
    if length(collection) == 1
        return collection
    end
    crosspoint1 = rand(1:length(collection) - 1)
    crosspoint2 = rand(crosspoint1+1:length(collection))
    return collection[crosspoint1:crosspoint2]
end

# next_fit algorithm to fit items in the given bins
function next_fit(bins, items, capacity)
    index = 1        
    for item in items
        bin = bins[index]
        if item.size <= fill(bin)
            push!(bin.items, item)
        else
            index += 1
            if index > length(bins)
                push!(bins, Bin(capacity, [item]))
                continue
            else
                push!(bins[index].items, item)
            end
        end
    end
    return bins
end

function validate_capacities(bins)
    return all([bin.capacity >= sum([item.size for item in bin.items]) for bin in bins])
end

# define a function that returns the remaining space in a given bin
function fill(bin::Bin)
    return bin.capacity - sum([item.size for item in bin.items])
end

#
function fitness2(solution)
    required_bins = 0
    total_fill = 0
    total_fill_deviation = 0
    e = 0.04
    p = 0
    for bin in solution
        if length(bin.items) > 0
            required_bins += 1
            total_fill += fill(bin)
            if fill(bin) > e
                p += 1
            end
        end
    end

    a = total_fill / required_bins

    for bin in solution
        if length(bin.items) > 0
            total_fill_deviation += abs(fill(bin) - a)
        end
    end

    b = total_fill_deviation / required_bins

    d = (p/required_bins) * e

    f = 1 - (a + b + d)
    if f > 1
        println("a: ", a)
        println("b: ", b)
        println("d: ", d)
    end
    return f
end

# function create_chromosome(items, indices)
function get_fitness(solution)
    fitness = 0
    k = 2
    for bin in solution
        if length(bin.items) > 0
            fitness += (sum([item.size for item in bin.items]) / bin.capacity) ^ k
        end
    end
    return fitness / length(bins)
end

function genetic_algorithm(items, bins, population_size, num_generations)
    population = []
    crossover_rate = 0.5
    mutation_rate = 0.03
    while length(population) < population_size
        solution = []
        while length(solution) < length(items)
            item = items[rand(1:length(items))]
            if !(item in solution)
                push!(solution, item)
            end
        end
        push!(population, solution)
    end

    best_index = 0
    best_configuration = []
    best_fitness = 0
    for generation in 1:num_generations
        configurations = [next_fit(deepcopy(bins), configuration, 1) for configuration in population]
        fitnesses = [get_fitness(configuration) for configuration in configurations]
        bindex = argmax(fitnesses)
        bfit = fitnesses[bindex]
        if best_fitness < bfit
            best_fitness = bfit
            best_index = bindex
            best_configuration = configurations[best_index]
        end
        
        no_of_solutions = 0
        intermediate_population = []
        while no_of_solutions < population_size
            if rand() <= crossover_rate
                parent1_index, parent2_index = roulette_wheel_selection(fitnesses)
                parent1 = population[parent1_index]
                parent2 = population[parent2_index]
                child = crossover(parent1, parent2)
                if rand() <= mutation_rate
                    child = mutation(child)
                end
                no_of_solutions += 1
                push!(intermediate_population, child)
            end
        end
        population = intermediate_population
        # population = elitism(intermediate_population, population)
    end

    
    return best_configuration, length(best_configuration)
end

function place_initial_items(items, capacity)
    # place items with size >= 0.5 in individual bins
    # this reduces the chromosome size to items with size < 0.5
    remaining_items = []
    bins = []
    for item in items
        if item.size >= 0.5
            push!(bins, Bin(capacity, [item]))
        else
            push!(remaining_items, item)
        end
    end
    return bins, remaining_items
end

function roulette_wheel_selection(fitnesses)
    # normalize the fitnesses to probabilities
    total_fitness = sum(fitnesses)
    probabilities = fitnesses ./ total_fitness
    
    # create a cumulative probability distribution
    cum_probs = cumsum(probabilities)
    
    # select two parents using the roulette wheel
    parents = []
    for i in 1:2
        r = rand()
        for j in eachindex(cum_probs)
            if r <= cum_probs[j]
                push!(parents, j)
                break
            end
        end
    end
    
    return parents
end

function repr(bin::Bin)
    println("Bin contents:")
    for item in bin.items
        println(item.id, ": ", item.size)
    end
end


function first_fit(bins, items, capacity)
    for item in items
        pushed = false
        for bin in bins
            if item.size <= fill(bin)
                push!(bin.items, item)
                pushed = true
            end
        end
        if !pushed
            push!(bins, Bin(capacity, [item]))
        end
    end
    return length(bins)
end

# function first_fit_decreasing(bins, items, capacity)
#     sizes = [item.size for item in items]
#     p = sortperm(sizes)

#     sorted_items = sort(items, by=i->i.size)
#     return first_fit(bins, sorted_items, capacity)
# end

BIN_CAPACITY = 1

items = generate_items(100, 1)
bins, remaining_items = place_initial_items(items, BIN_CAPACITY)

# print(length(bins))
if length(items) == 0
    for bin in bins
        repr(bin)
    end
    println("number of bins used: ", length(bins))
else
    println("GENETIC ALGORITHM SOLUTION")
    best_configuration, num_bins = genetic_algorithm(remaining_items, bins, 30, 100)
    println("number of bins used: ", num_bins)
    println("FIRST FIT SOLUTION")
    println("number of bins used: ", first_fit(bins, remaining_items, 1))

end