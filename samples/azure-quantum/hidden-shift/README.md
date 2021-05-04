---
page_type: sample
description: Find hidden shifts in Boolean functions, using the Azure Quantum service
languages:
- qsharp
- python
products:
- qdk
- azure-quantum
---

# Finding hidden shift of bent functions using the Azure Quantum service

This sample demonstrates how to use Q# and Azure Quantum together to learn the hidden shift of bent functions.

This sample is implemented as a _standalone executable_, such that no C# or Python host is needed.
The program takes one command-line option, `--n-qubits`, to control the number of qubits used to sample a random number.

## Running the sample on a local simulator

```dotnetcli
dotnet run -- --simulator QuantumSimulator --pattern-int 6 --register-size 4
```

## Running the sample on Azure Quantum

Make sure that you have [created and selected a quantum workspace](https://docs.microsoft.com/azure/quantum/how-to-create-quantum-workspaces-with-the-azure-portal), and then run the following at the command line, substituting `TARGET` with the target that you would like to run against (e.g.: `ionq.qpu` or `honeywell.hqs-lt-1.0`):

```azcli
az quantum execute --target-id TARGET -- --pattern-int 6 --register-size 3
```

For a full list of available QIO and quantum computing targets, run:

```azcli
az quantum target list --output table
```

## Manifest

- [HiddenShift.csproj](https://github.com/microsoft/quantum/blob/main/samples/azure-quantum/hidden-shift/HiddenShift.csproj): Main Q# project file for this sample.
- [HiddenShift.qs](https://github.com/microsoft/quantum/blob/main/samples/azure-quantum/hidden-shift/HiddenShift.qs): Main Q# program for this sample.
