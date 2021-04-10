# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
import qsharp
from Microsoft.Quantum.Samples.GaussianPreparation import RunProgram
import matplotlib.pyplot as plt

def main():
    n_qubits = 7
    std_dev = (2**n_qubits)/6. 
    mean = 2**(n_qubits-1) - 0.5

    RunProgram()

    # read the probability amplitudes of result state into list
    list = []
    with open('gaussian_wavefcn.txt', 'r', encoding="utf8") as file:
        for line in file:
            # cut out probability amplitudes
            ampl = None
            for i in range(len(line)):
                if line[i] == '[':
                    ampl = line[(i+2):(i+10)]
                    break
            if ampl:
                print(ampl)
                list.append(float(ampl))
    print(list)

    # plot list
    plt.plot(list)
    # save the plot to file
    # plt.savefig('wavefunction.png')
    plt.savefig('wavefunction_recursive.png')
    plt.show()

if __name__ == "__main__":
    main()  