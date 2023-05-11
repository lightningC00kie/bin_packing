The bin-packing problem is as follows: 
The task is to pack a set of items of different size into bins of 
fixed size in such way that minimal number bins is used.

This is an implementation of the bin-packing problem solved
using genetic algorithms in Julia. The algorithm encodes a
solution as a chromosome which is a list of items. The items
are then placed into bins using the next-fit algorithm. Each
solution's fitness is calculated and crossover takes place
via roulette-wheel selection. The output of the program
is the number of bins used to pack the items.

The genetic algorithm used to solve this problem is heavily influenced
by [2] from the references. 

References from:
[1] https://www.macs.hw.ac.uk/~dwcorne/Teaching/falkenauer96hybrid.pdf
[2] https://www.tandfonline.com/doi/pdf/10.1080/00207169708804561



