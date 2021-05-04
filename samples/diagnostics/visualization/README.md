---
page_type: sample
languages:
- qsharp
products:
- qdk
description: "Visualizing quantum programs in Q# notebooks."
urlFragment: visualization
---

# Visualizing Quantum Programs

This sample demonstrates:

- Using `%trace` to visualize the execution path of a Q# program.
- Using `%debug` to step through the execution of a Q# program.

In this sample, you can use the `%trace` and `%debug` magic commands provided in Q# notebooks to visualize the execution path of a Q# program and to analyze the state of the quantum registers at each step of the program.

## Prerequisites

- The Microsoft [Quantum Development Kit](https://docs.microsoft.com/azure/quantum/install-overview-qdk/).

## Running the Sample

This sample is designed to be run from Jupyter Notebook.
To set up your development environment to run Jupyter Notebooks, follow the steps explained in the [Q# Quickstart: Jupyter guide](https://docs.microsoft.com/azure/quantum/install-jupyter-qkd).

Once this is set up, from the terminal, you can run the following command:

```Command Line
jupyter notebook
```

## Manifest

- [Visualizing Quantum Programs.ipynb](https://github.com/microsoft/Quantum/blob/main/samples/diagnostics/visualization/Visualizing%20Quantum%20Programs.ipynb): Main Q# notebook for this sample.

## Further resources

- [`%trace` magic command documentation](https://docs.microsoft.com/qsharp/api/iqsharp-magic/trace)
- [`%debug` magic command documentation](https://docs.microsoft.com/qsharp/api/iqsharp-magic/debug)
