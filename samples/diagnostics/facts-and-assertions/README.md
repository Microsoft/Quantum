---
page_type: sample
languages:
- qsharp
products:
- qdk
description: "Using facts and assertions to diagnose quantum programs in Q#."
urlFragment: facts-and-assertions
---

# Using Facts and Assertions

This sample demonstrates:

- Using facts to check conditions on the values of Q# variables.
- Using assertions on quantum simulators to check conditions on the state of quantum registers.

In this sample, you can use Q# to check the correctness of quantum programs with both _facts_ (functions that check conditions on the values of their inputs) and _assertions_ (operations that check conditions on the state of their inputs). Both facts and assertions can be used together to help understand bugs in quantum programs, and to write unit tests that help ensure that your Q# programs work correctly.

## Prerequisites

- The Microsoft [Quantum Development Kit](https://docs.microsoft.com/azure/quantum/install-overview-qdk/).

## Running the Sample

This sample is designed to be run from Jupyter Notebook.
To set up your development environment to run Jupyter Notebooks, follow the steps explained in the [Q# Quickstart: Jupyter guide](https://docs.microsoft.com/azure/quantum/install-jupyter-qkd).

Once this is set up, from the terminal, you can run the following command:

```Command Line
jupyter notebook
```

Alternatively, these notebooks can be started and run in the VSCode editor. To get set up with VSCode, please follow the steps laid out in the [Q# Quickstart: VSCode guide](https://docs.microsoft.com/azure/quantum/install-command-line-qdk).

## Manifest

- [Facts and Assertions.ipynb](https://github.com/microsoft/Quantum/blob/main/samples/diagnostics/facts-and-assertions/Facts%20and%20Assertions.ipynb): Main Q# notebook for this sample.

## Further resources

- [Use Q#: Test and debug](https://docs.microsoft.com/azure/quantum/user-guide/testing-debugging#facts-and-assertions)
