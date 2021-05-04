---
page_type: sample
languages:
- qsharp
- python
- csharp
products:
- qdk
description: "This sample implements using the quantum machine learning library to train a sequential model on the half-moons dataset."
---

# Training sequential models with Q#, using built-in datasets

This sample uses Q# and the Microsoft.Quantum.MachineLearning library to train a simple sequential model.
The model is trained on the [wine dataset](https://archive.ics.uci.edu/ml/datasets/wine) from the [UCI Machine Learning Repository](https://archive.ics.uci.edu/), using a classifier structure defined in Q#.


## Prerequisites

- The Microsoft [Quantum Development Kit](https://docs.microsoft.com/azure/quantum/install-overview-qdk/).

## Running the Sample

This sample can be run in a number of different ways, depending on your preferred environment.

### Python in Visual Studio Code or the Command Line ###

At a terminal, run the following command:

```powershell
python host.py
```

### C# in Visual Studio Code or the Command Line

At a terminal, run the following command:

```powershell
dotnet run
```

### C# in Visual Studio 2019

Open the folder containing this sample in Visual Studio ("Open a local folder" from the Getting Started screen or "File → Open → Folder..." from the menu bar) and set `Wine.csproj` as the startup project.
Press Start in Visual Studio to run the sample. 

## Manifest

- [Training.qs](https://github.com/microsoft/Quantum/blob/main/samples/machine-learning/wine/Training.qs): Q# code implementing quantum operations for this sample.
- [host.py](https://github.com/microsoft/Quantum/blob/main/samples/machine-learning/wine/host.py): Python code to interact with and print out results of the Q# operations for this sample.
- [Host.cs](https://github.com/microsoft/Quantum/blob/main/samples/machine-learning/wine/Host.cs): C# code to interact with and print out results of the Q# operations for this sample.
- [Wine.csproj](https://github.com/microsoft/Quantum/blob/main/samples/machine-learning/wine/Wine.csproj): Main C# project for the sample.
