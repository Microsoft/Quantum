---
page_type: sample
languages:
- qsharp
products:
- qdk
urlFragment: gaussian-initial-state
description: "This sample demonstrates using Quantum Development Kit to prepare the Gaussian initial state."
---

# Gaussian Initial State Sample

This sample demonstrates the use of the Quantum Development Kit for preparing the Gaussian initial state.

The goal of the algorithm is to prepare a quantum state that encodes the Gaussian wavefunction using probability amplitudes. The Gaussian state can be defined via a recursive definition, as described in this paper: https://arxiv.org/abs/0801.0342.

![Image of Gaussian state definition](https://github.com/microsoft/Quantum/blob/main/samples/Gaussian_initial_state/gaussian_definition.JPG)

We implemented this algorithm in two ways in Q#. The first is using a for-loop implementation. This approach is outlined in Guen Prawiroatmodjo's blog post: https://guenp.medium.com/preparing-a-gaussian-wave-function-in-q-695c3941f6dc. The second is by recursion. 

The algorithm recursively calls the following subroutine, using the input data (sigma0, mu0) = (sigma, mu).
1. (a) Calculate alpha from sigma and mu

   (b) Apply the rotation operator R(alpha) to the 0th qubit
2. Compute (sigma1, mu1), where sigma1 = sigma0/2 and mu1 = mu0/2 if the previously rotated qubit is |0> and mu1 = (mu0 - 1)/2 if it is |1>
3. On the remaining N-1 qubits prepare state |psy(sigma1, mu1, N-1)>

Note that after the last ((N-1)th) qubit, we proceed only through step 1 (b), as after this qubit is rotated we do not need another pair of parameters.

Both approaches use the [`ApplyControlledOnBitString` operation](https://docs.microsoft.com/qsharp/api/qsharp/microsoft.quantum.canon.applycontrolledonbitstring) in Q#. You can specify which implementation to use in the sample.

## Prerequisites ##

- The Microsoft [Quantum Development Kit](https://docs.microsoft.com/quantum/install-guide/).

## Running the Sample

To run the sample, use the `dotnet run` command from your terminal.
To read and plot the result state, use the `python read_state.py` command from your terminal.
You can specify to either use the basic for-loop implementation or the recursive implementation in the Program.qs file. 

## Manifest ##

- [Gauss_wavefcn.qs](https://github.com/microsoft/Quantum/blob/main/samples/Gaussian_initial_state/Gauss_wavefcn.qs): Q# code defining how to prepare Gaussian state.
- [Program.qs](https://github.com/microsoft/Quantum/blob/main/samples/gaussian_initial_state/Program.qs): Q# entry point to interact with and print out results of the Q# operations for this sample.
- [read_state.py](https://github.com/microsoft/Quantum/blob/main/samples/gaussian_inital_state/read_state.py): Python code to plot the result quantum state of the Q# operations for this sample.
- [Gaussian_initial_state.csproj](https://github.com/microsoft/Quantum/blob/main/samples/gaussian_initial_state/Gaussian_initial_state.csproj): Main Q# project for the example.
