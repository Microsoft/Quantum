namespace Microsoft.Quantum.Samples.GaussianPreparation {
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic; 
    open Microsoft.Quantum.Arrays;

    @EntryPoint()
    operation RunProgram() : Unit {
        let nQubits = 7;
        let stdDev = IntAsDouble((2 ^ nQubits)) / 6.;
        let mean = IntAsDouble(2 ^ (nQubits - 1)) - 0.5;
        let bitstring = EmptyArray<Bool>();
        using (register = Qubit[nQubits]) {
            // Call the for loop implementation.
            // Gauss_wavefcn(std_dev, mean, nQubits, register);
            // Call the recursive implementation.
            PrepareGaussWavefcnRecursive(stdDev, mean, nQubits, bitstring, register);
            // Output result quantum state the file.
            DumpRegister("gaussian_wavefcn.txt", register);
            ResetAll(register);
        }
    }
}
