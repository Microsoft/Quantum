---
page_type: sample
languages:
- qsharp
- python
- csharp
products:
- qdk
description: "This sample uses the CHSH game to demonstrate how Q# programs can be used to prepare and work with entanglement."
urlFragment: validating-quantum-mechanics
---

# Validating Quantum Mechanics with the CHSH Game

This sample demonstrates:
- How to prepare entangled states with Q#.
- How to measure part of an entangled register.
- Using Q# to understand superposition and entanglement.

In this sample, you can use Q# to prepare qubits in an entangled state, and to check that measuring these qubits lets you win a game known as the _CHSH game_ more often than you can without entanglement.
This game helps us understand entanglement, and has even been used experimentally to help test that the universe really is quantum mechanical in nature.

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

### C# in Visual Studio 2019

Open the folder containing this sample in Visual Studio ("Open a local folder"
from the Getting Started screen or "File → Open → Folder..." from the menu bar)
and set `CHSHGame.csproj` as the startup project. 
Press Start in Visual Studio to run the sample. 

## Manifest

- [Game.qs](https://github.com/microsoft/Quantum/blob/main/samples/algorithms/chsh-game/Game.qs): Q# code implementing the game.
- [host.py](https://github.com/microsoft/Quantum/blob/main/samples/algorithms/chsh-game/host.py): Python host program to call into the Q# sample.
- [Host.cs](https://github.com/microsoft/Quantum/blob/main/samples/algorithms/chsh-game/Host.cs): C# code to call the operations defined in Q#.
- [CHSHGame.csproj](https://github.com/microsoft/Quantum/blob/main/samples/algorithms/chsh-game/CHSHGame.csproj): Main C# project for the sample.

## Further resources

- [Measurement concepts](https://docs.microsoft.com/azure/quantum/concepts-pauli-measurements)
