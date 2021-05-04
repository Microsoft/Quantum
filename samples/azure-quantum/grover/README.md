---
page_type: sample
description: Search unstructured data on quantum hardware, using the Azure Quantum service
languages:
- qsharp
products:
- qdk
- azure-quantum
---

# Simple Grover's search with the Azure Quantum service

This sample demonstrates how to use Q# and the Azure Quantum service together to search for data with Grover's algorithm, also known as amplitude amplification.
By applying a sequence of reflections, this state prepares a register of qubits in a state marked by a given quantum operation known as an _oracle_.
The oracle used in this sample checks if its input matches a given integer, so that the computational basis state corresponding to that index is prepared with high probability.

This sample is implemented as a _standalone executable_, such that no C# or Python host is needed.
The program takes one command-line option, `--n-qubits`, to control the number of qubits that are prepared using amplitude amplification.

## Running the sample on a local simulator

```dotnetcli
dotnet run -- --simulator QuantumSimulator --n-qubits=3 --idx-marked=6
```

## Running the sample on the Azure Quantum service

Make sure that you have [created and selected a quantum workspace](https://docs.microsoft.com/azure/quantum/how-to-create-quantum-workspaces-with-the-azure-portal), and then run the following at the command line, substituting `TARGET` with the target that you would like to run against (e.g.: `ionq.qpu` or `honeywell.hqs-lt-1.0`):

```azcli
az quantum execute --target-id TARGET -- --n-qubits=4 --idx-marked=6
```

For a full list of available QIO and quantum computing targets, run:

```azcli
az quantum target list --output table
```

## Manifest

- [Grover.csproj](https://github.com/microsoft/quantum/blob/main/samples/azure-quantum/grover/Grover.csproj): Main Q# project file for this sample.
- [Reflections.qs](https://github.com/microsoft/quantum/blob/main/samples/azure-quantum/grover/Reflections.qs): Definitions for each reflection used in Grover's search.
- [SimpleGrover.qs](https://github.com/microsoft/quantum/blob/main/samples/azure-quantum/grover/SimpleGrover.qs): Main Q# program for this sample.
