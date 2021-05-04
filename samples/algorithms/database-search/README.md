---
page_type: sample
languages:
- qsharp
- python
- csharp
products:
- qdk
description: "This sample shows how to use Q# to search for a marked item with Grover's algorithm."
---

# Database Search Sample

This sample walks through Grover's search algorithm. Oracles implementing the database are explicitly constructed together with all steps of the algorithm. This features two examples -- the first implements the steps of Grover's algorithm manually. The second applies amplitude amplification functions in the canon to automate many steps of the implementation.

## Prerequisites

- The Microsoft [Quantum Development Kit](https://docs.microsoft.com/azure/quantum/install-overview-qdk/).

## Running the Sample

This sample can be run in a number of different ways, depending on your preferred environment.

### Python in Visual Studio Code or the Command Line

At a terminal, run the following command:

```powershell
python host.py
```

### C# in Visual Studio Code or the Command Line

At a terminal, run the following command:

```powershell
dotnet run
```

### Running the Sample in Jupyter Notebook

This sample can also be viewed using Jupyter Notebook.
To do so, ensure that you have the IQ# kernel installed using the instructions in the [getting started guide](https://docs.microsoft.com/azure/quantum/install-jupyter-qkd).
Then, start a new Jupyter Notebook session from this directory:

```powershell
cd Samples/src/DatabaseSearch
jupyter notebook
```

## Manifest

- [DatabaseSearch.qs](./DatabaseSearch.qs): Q# code implementing quantum operations for this sample.
- [Program.cs](./Program.cs): C# code to interact with and print out results of the Q# operations for this sample.
- [DatabaseSearchSample.csproj](./DatabaseSearchSample.csproj): Main C# project for the sample.
- [Database Search.ipynb](./Database%20Search.ipynb): The sample as a Jupyter Notebook.

