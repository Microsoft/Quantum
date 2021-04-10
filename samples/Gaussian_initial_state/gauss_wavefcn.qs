// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
namespace Microsoft.Quantum.Samples.GaussianPreparation {
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Arithmetic;

    //////////////////////////////////////////////////////////////////////////
    // Introduction //////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////

    // This program prepares a quantum state that encodes a Gaussian function using
    // probability amplitudes, given the standard deviation, mean, and number of 
    // qubits.

    //////////////////////////////////////////////////////////////////////////
    // Gaussian initial state ////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////

    /// # Summary
    /// Computes a single term in the normalization factor.
    /// # Input
    /// ## sigma
    /// Standard deviation.
    /// ## mu
    /// Mean.
    /// ## N
    /// The term in the normalization factor.
    function NormTerm (sigma: Double, mu: Double, N: Int) : Double {
        let n = IntAsDouble(N);
        return ExpD(-((n - mu) ^ 2.) /sigma ^ 2.);
    }

    /// # Summary
    /// Computes the normalization factor.
    /// # Input
    /// ## sigma
    /// Standard deviation.
    /// ## mu
    /// Mean.
    /// ## N
    /// The limit of the sum in the normalization factor.
    function Norm (sigma: Double, mu: Double, N: Int) : Double {
        mutable sum = 0.;
        for (n in -N..N) {
            set sum = PlusD(sum, NormTerm(sigma, mu, n));
        }
        return sum;
    }

    /// # Summary
    /// Computes the rotation angle.
    /// # Input
    /// ## sigma
    /// Standard deviation.
    /// ## mu
    /// Mean.
    /// ## N
    /// The limit of the sum in the normalization factor.
    function Angle (sigma: Double, mu: Double, N : Int) : Double {
        return ArcCos(Sqrt(Norm(sigma/2., mu/2., N)/Norm(sigma, mu, N)));
    }

    /// # Summary
    /// Return a list of n-bit strings.
    /// # Input
    /// ## nQubits
    /// The number of bits.
    function QubitStrings (nQubits: Int) : Bool[][] {
        return MappedOverRange(IntAsBoolArray(_, nQubits), 0..PowI(2, nQubits) - 1);
    }

    
    /// # Summary
    /// Given an n-bit string, return the corresponding mean for the rotation angle
    /// at recursion level n.
    /// # Input
    /// ## qub
    /// The n-bit string.
    /// ## mu
    /// Mean.
    function MeanQubitCombo (qub: Bool[], mu: Double) : Double {
        mutable mu_out = mu;
        for (bit in qub) {
            set mu_out += mu_out/2. - (bit ? 0. | -0.5);
        }
        return mu_out;
    }

    /// # Summary
    /// At recursion level n, return a list of all the means used for the various rotation angles.
    /// # Input
    /// ## mu
    /// Mean.
    /// ## n
    /// Recursion level.
    function LevelMeans (mu: Double, n: Int) : Double[] {
        mutable list_mu_out = ConstantArray(2^n, 0.);
        let qb_strings = QubitStrings(n);
        for (i in 0..2^n-1) {
            let mu_out = MeanQubitCombo(ElementAt(i, qb_strings), mu);
            set list_mu_out w/= i <- mu_out;
        }
        return list_mu_out;
    }

    
    /// # Summary
    /// At recursion level n, return a list of all the rotation angles.
    /// # Input
    /// ## sigma
    /// Standard deviation
    /// ## mu
    /// Mean.
    /// ## n
    /// Recursion level.
    function LevelAngles(sigma: Double, mu: Double, n: Int) : Double[] {
        let sigma_out = sigma/(2.^IntAsDouble(n));
        let list_mu = LevelMeans(mu, n);
        mutable angles_out = ConstantArray(2^n, 0.);
        for (i in IndexRange(list_mu)) {
            mutable mu_ = ElementAt(i, list_mu);
            set angles_out w/= i <- Angle(sigma_out, mu_, 10^3);
        }
        return angles_out;
    }

    /// # Summary
    /// Prepare the Gaussian wavefunction on a register.
    /// # Input
    /// ## sigma
    /// Standard deviation.
    /// ## mu_
    /// Mean.
    /// ## num_qubits
    /// The number of qubits.
    operation PrepareGaussWavefcn (sigma: Double, mu_: Double, numQubits: Int, register: Qubit[]) : Unit is Adj {
        // Compute angle.
        mutable theta = Angle(sigma, mu_, 10^3);
        // Rotate the 1st qubit by angle theta.
        Ry(2. * theta, register[0]);
        for (n in 1..numQubits-1) {
            // Compute a list of all the rotation angles at level n.
            let ListLevelAngles = LevelAngles(sigma, mu_, n);
            // For each bitstring at current level, apply a controlled rotation to the 
            // next qubit.
            for (i in 0..2^n - 1){
                let bitstring = IntAsBoolArray(i,n);
                mutable rotation = Ry(2.*ListLevelAngles[i], _);
                ApplyControlledOnBitString(bitstring, rotation, register[0..n-1], register[n]);                    
            }
        }
    }    

    /// # Summary
    /// Prepare the Gaussian wavefunction on a register using the recursive implementation.
    /// # Input
    /// ## sigma
    /// Standard deviation.
    /// ## mu_
    /// Mean.
    /// ## num_qubits
    /// The number of qubits.
    /// ## bitstring
    /// An empty bitstring.
    /// ## register
    /// The qubit register.
    operation PrepareGaussWavefcnRecursive (sigma: Double, mu: Double, numQubits: Int, bitstring: Bool[], 
    register: Qubit[]) : Unit is Adj {
        // If the number of qubits is 1, then simply do a rotation to the qubit.
        if (numQubits == 1) {
            let alpha = Angle(sigma, mu, 10^3);
		    Ry(2.*alpha, register[0]);
        }    
        // If there are more than 1 qubit, contruct the state recursively.
        elif (numQubits > 1) {
            let alpha = Angle(sigma, mu, 10^3);
            // If the bitstring is empty, or it's the 1st qubit.
            if (IsEmpty(bitstring)) {
                // Rotate the 1st qubit.
                Ry(2.*alpha, register[0]);
            }
            // If the bitstring is not empty but not longer than the number of qubits, or
            // it's not the 1st qubit but not after the last qubit.
            elif (Length(bitstring) < numQubits) {
                // Apply the controlled rotation with the bitstring to the next qubit.
                let rotation = Ry(2.*alpha, _);
                let n = Length(bitstring);
                ApplyControlledOnBitString(bitstring, rotation, register[0..n-1], register[n]);
            }	 
            if (Length(bitstring) != numQubits) {
                // Add a 0 to the bitstring and call the function recursively.
                let bitstring0 = bitstring + [false];
                PrepareGaussWavefcnRecursive(sigma/2., mu/2., numQubits, bitstring0, register);
                // Add a 1 to the bitstring and call the function recursively.
                let bitstring1 = Flattened([bitstring, [true]]);
                PrepareGaussWavefcnRecursive(sigma/2., (mu-1.)/2., numQubits, bitstring1, register);    
            } 
        } 
    }
	
}
