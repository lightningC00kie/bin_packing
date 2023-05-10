This is an implementation of the bin-packing problem solved
using genetic algorithms in Julia. The problem setup is given
in the JSON format specified in the user documentation.

The bin-packing problem is as follows: 
The task is to pack a set of items of different size into bins of 
fixed size in such way that minimal number bins is used.

The genetic algorithm used to solve this problem is heavily influenced
by paper [1] from the references. 

References from:
[1] https://www.macs.hw.ac.uk/~dwcorne/Teaching/falkenauer96hybrid.pdf
[2] https://www.tandfonline.com/doi/pdf/10.1080/00207169708804561
