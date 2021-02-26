# Bitonic-Sort
Implement the [Bitonic Sort](https://en.wikipedia.org/wiki/Bitonic_sorter) algorithm in Assembly LEGv8. The program takes in an unsorted list of a size that is a power of 2, and outputs the sorted list.

## Helper Functions
All functions definitions could be found [here](https://github.com/Geniussh/Bitonic-Sort/blob/main/BitonicSort.pdf).  

## Usage
The algorithm is run and simulated in a LEGv8 Simulator [legiss.jar](https://github.com/Geniussh/Bitonic-Sort/blob/main/legissFX071.jar).  
Load program for BitonicSort.s and load data for test.data.  
The first line of output shows the result of testing FindM, which returns the largest power of 2 that is less than size of the list.  
The second line of output prints the original list while the last line prints the sorted list.

Output:
```
16
2 5 7 6 8 1 3 4
1 2 3 4 5 6 7 8
```
