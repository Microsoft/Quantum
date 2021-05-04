---
page_type: sample
languages:
- qsharp
- csharp
products:
- qdk
description: "This sample uses Grover's search algorithm to solve Sudoku puzzles."
---

# Solving Sudoku using Grover's Algorithm


This program demonstrates solving Sudoku puzzle using Grovers algorithm.
     
The code supports both 4x4 and 9x9 Sudoku puzzles.
          
For 4x4 puzzles, the same rules apply:

- The numbers 0 to 3 may only appear once per row, column and 2x2 sub squares 
```
     As an example              has solution
     _________________          _________________
     |   | 1 |   | 3 |          | 0 | 1 | 2 | 3 |  
     -----------------          -----------------
     | 2 |   |   | 1 |          | 2 | 3 | 0 | 1 |  
     -----------------          -----------------
     |   |   | 3 | 0 |          | 1 | 2 | 3 | 0 |  
     -----------------          -----------------
     | 3 |   | 1 |   |          | 3 | 0 | 1 | 2 |  
     -----------------          -----------------
```
Sudoku is a graph coloring problem where graph edges must connect nodes of different colors
In our case, graph nodes are puzzle squares and colors are the Sudoku numbers. 
Graph edges are the constraints preventing squares from having the same values. 
In the above example, the constraints for the top row are
```
       _________
      | ______   \                   _____   
      || __   \   \                  | __  \                        __
     _|||__\___\_ _\__         ______||__\___\__          _________|___\__ 
     |   | 1 |   | 3 |         |   | 1 |   | 3 |         |   | 1 |   | 3 | 
     -----------------         -----------------         -----------------
```
To reduce the number of qubits, we only use qubits for empty squares.
Each empty square gets 2 qubits to encode the numbers 0 to 3.
We define the puzzle using 2 data structures.

- A list of edges connecting empty squares
- A list of constraints on empty squares to the initial numbers in the puzzle (starting numbers)

For example, for the row above the empty squares have indexes 
```
     _________________
     | 0 |   | 1 |   |
     -----------------
```
and `emptySquareEdges` is the array of edges. 
For example, cell 0 can't have the same number (color) as cell 1:
emptySquareEdges = (0,1)      
and `startingNumberConstraints` is the array of (Cell#, constraint) 
For example, empty cell 0 can't have value 1 or 3:
startingNumberConstraints = (0,1)  (0,3)  (1,1)  (1,3)   
     
Note that the puzzles are initially defined in C# using numbers from 1 to 4, or 1 to 9. 
However, when solving this quantumly and encoding these values into qubits, 
the numbers are changed to 0 to 3 and 0 to 8 and then converted back. 
This allows a 4x4 puzzle to be solved using 2 qubits per missing number.

The code can also solve 9x9 Sudoku puzzles using 4 qubits per number. 
However, trying to use more than 8 qubits (2 empty squares) in a simulation becomes very slow, 
so here we only run it for 1 or 2 missing squares in a 9x9 puzzle.


The graph coloring code is based on the [Graph Coloring Kata](https://github.com/microsoft/QuantumKatas/tree/main/GraphColoring) 
with the following changes

- allow for varying qubits per color
- constraints on Vertex colors based on initial colors when you start
- for 9x9 puzzles, 4 bits per color are used but the colors in the solution can only be 0 to 8

## Prerequisites ##

- The Microsoft [Quantum Development Kit](https://docs.microsoft.com/azure/quantum/install-overview-qdk/).

## Running the Sample ##

To run the sample, use the `dotnet run` command from your terminal.
This will run all the test puzzles. 
You can also choose a specific puzzle to solve by adding the puzzle name as below
    
-   4x4-classic : test classic algorthm on a 4x4 puzzle
-   4x4-1 : test Quantum solution of 4x4 puzzle missing 1 number
-   4x4-3 : test Quantum solution of 4x4 puzzle missing 3 numbers
-   4x4-4 : test Quantum solution of 4x4 puzzle missing 4 numbers
-   9x9-1 : test classic algorithm and Quantum solution on a 
            9x9 puzzle with 1 missing number
-   9x9-2 : test Quantum solution on a 
            9x9 puzzle with 2 missing numbers
-   9x9-64   : test classic algorithm and Quantum solution on a 
            9x9 puzzle with 64 missing numbers

For example, `dotnet run 4x4-4` will run the Quantum solution for a 4x4 puzzle with 4 missing numbers

## Manifest ##

- [ColoringGroverWithConstraints.qs](ColoringGroverWithConstraints.qs): Q# code implementing graph coloring with flexible number of bits per color and ability to specify constraints on the colors found per Vertex.  A custom oracle for coloring with only 9 colors is also implemented.
- [Program.cs](Program.cs): C# code with Sudoku test problems to solve using classical or Quantum code. It then checks and displays the results.
- [Sudoku.qs](Sudoku.qs): Q# code which accepts edges and constraints and calls Grovers algorthm with the coloring oracle. Also checks the result is correct.
- [SudokuClassic.cs](SudokuClassic.cs): C# code to solve a Sudoku puzzle using classical code.
- [SudokuQuantum.cs](SudokuQuantum.cs): C# code to solve a Sudoku puzzle by transforming it into a graph problem (edges and starting number constraints), and call the Quantum SolvePuzzle operation to solve it.
- [SudokuGroverSample.csproj](SudokuGroverSample.csproj): Main project for the sample.

## Sample Output ##


    dotnet run 4x4-4

    Quantum Solving 4x4 with 4 missing numbers.
    -----------------
    |   |   | 3 | 4 |
    -----------------
    |   |   | 1 | 2 |
    -----------------
    | 2 | 3 | 4 | 1 |
    -----------------
    | 4 | 1 | 2 | 3 |
    -----------------
    Running Quantum test with #Vertex = 4
      Bits Per Color = 2
      emptySquareEdges = [(1, 0),(2, 0),(3, 0),(3, 1),(3, 2)]
      startingNumberConstraints = [(0, 1),(0, 3),(0, 2),(1, 2),(1, 0),(1, 3),(2, 1),(2, 3),(2, 0),(3, 2),(3, 0),(3, 1)]
      Estimated #iterations needed = 12
      Size of Sudoku grid = 4x4
    Trying search with 1 iterations...
    Trying search with 2 iterations...
    Trying search with 3 iterations...
    Got Sudoku solution: [0,1,2,3]
    Got valid Sudoku solution: [0,1,2,3]
    Solved puzzle.
    Result verified correct.
    -----------------
    | 1 | 2 | 3 | 4 |
    -----------------
    | 3 | 4 | 1 | 2 |
    -----------------
    | 2 | 3 | 4 | 1 |
    -----------------
    | 4 | 1 | 2 | 3 |
    -----------------
    

    dotnet run 9x9-2

    Solving 9x9 with 2 missing numbers using Quantum Computing.
    -------------------------------------
    |   | 7 | 3 | 8 | 9 | 4 | 5 | 1 | 2 |
    -------------------------------------
    | 9 |   | 2 | 7 | 3 | 5 | 4 | 8 | 6 |
    -------------------------------------
    | 8 | 4 | 5 | 6 | 1 | 2 | 9 | 7 | 3 |
    -------------------------------------
    | 7 | 9 | 8 | 2 | 6 | 1 | 3 | 5 | 4 |
    -------------------------------------
    | 5 | 2 | 6 | 4 | 7 | 3 | 8 | 9 | 1 |
    -------------------------------------
    | 1 | 3 | 4 | 5 | 8 | 9 | 2 | 6 | 7 |
    -------------------------------------
    | 4 | 6 | 9 | 1 | 2 | 8 | 7 | 3 | 5 |
    -------------------------------------
    | 2 | 8 | 7 | 3 | 5 | 6 | 1 | 4 | 9 |
    -------------------------------------
    | 3 | 5 | 1 | 9 | 4 | 7 | 6 | 2 | 8 |
    -------------------------------------
    Running Quantum test with #Vertex = 2
      Bits Per Color = 4
      emptySquareEdges = [(1, 0)]
      startingNumberConstraints = [(0, 8),(0, 7),(0, 6),(0, 4),(0, 0),(0, 3),(0, 1),(0, 2),(1, 6),(1, 3),(1, 8),(1, 1),(1, 2),(1, 5),(1, 7),(1, 4)]
      Estimated #iterations needed = 12
      Size of Sudoku grid = 9x9
    Trying search with 1 iterations...
    Trying search with 2 iterations...
    Got Sudoku solution: [5,0]
    Got valid Sudoku solution: [5,0]
    Solved puzzle.
    Result verified correct.
    -------------------------------------
    | 6 | 7 | 3 | 8 | 9 | 4 | 5 | 1 | 2 |
    -------------------------------------
    | 9 | 1 | 2 | 7 | 3 | 5 | 4 | 8 | 6 |
    -------------------------------------
    | 8 | 4 | 5 | 6 | 1 | 2 | 9 | 7 | 3 |
    -------------------------------------
    | 7 | 9 | 8 | 2 | 6 | 1 | 3 | 5 | 4 |
    -------------------------------------
    | 5 | 2 | 6 | 4 | 7 | 3 | 8 | 9 | 1 |
    -------------------------------------
    | 1 | 3 | 4 | 5 | 8 | 9 | 2 | 6 | 7 |
    -------------------------------------
    | 4 | 6 | 9 | 1 | 2 | 8 | 7 | 3 | 5 |
    -------------------------------------
    | 2 | 8 | 7 | 3 | 5 | 6 | 1 | 4 | 9 |
    -------------------------------------
    | 3 | 5 | 1 | 9 | 4 | 7 | 6 | 2 | 8 |
    -------------------------------------
