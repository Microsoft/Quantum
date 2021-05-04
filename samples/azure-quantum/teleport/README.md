---
page_type: sample
description: Run quantum teleportation on hardware, using the Azure Quantum service
languages:
- qsharp
products:
- qdk
- azure-quantum
---

# Quantum teleportation sample

This sample demonstrates how to use Q# and the Azure Quantum service together to teleport quantum data within a device.

This sample is implemented as a _standalone executable_, such that no C# or Python host is needed.

## Running the sample on a local simulator

```dotnetcli
dotnet run -- --simulator QuantumSimulator --prep-basis PauliX --meas-basis PauliX
```

## Running the sample on the Azure Quantum service

Make sure that you have [created and selected a quantum workspace](https://docs.microsoft.com/azure/quantum/how-to-create-quantum-workspaces-with-the-azure-portal), and then run the following at the command line, substituting `TARGET` with the target that you would like to run against (e.g.: `honeywell.hqs-lt-1.0`).

```azcli
az quantum execute --target-id TARGET -- --prep-basis PauliX --meas-basis PauliX
```

> **⚠ NOTE:** In order to run this sample, the target must support comparing measurement results.

For a full list of available QIO and quantum computing targets, run:

```azcli
az quantum target list --output table
```

## Manifest

- [Teleport.csproj](https://github.com/microsoft/quantum/blob/main/samples/azure-quantum/teleport/Teleport.csproj): Main Q# project file for this sample.
- [Teleport.qs](https://github.com/microsoft/quantum/blob/main/samples/azure-quantum/teleport/Teleport.qs): Main Q# program for this sample.
