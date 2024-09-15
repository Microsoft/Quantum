// MULTIUNITARY 
// A TRANSFORMATION UTILITY FOR JORDAN-WIGNER H TERMS
// WRITTEN BY CHRISTOPHER KANG AT THE UNIVERSITY OF WASHINGTON, SEATTLE
// RELEASE 1.0 - MARCH 20TH, 2019
// CSE 490Q - SVORE

// MultiUnitary is a utility for our VQE package. It allows the conversion of H-terms into
// an array of unitaries to find the expectation values.
// This is modeled after the original JW Set
namespace MultiUnitary {
    
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Extensions.Math;
    open Microsoft.Quantum.Chemistry;
    
    // This namespace has methods needed to convert a generatorIndex into 
    // a set of the constituent gates needed to find the expectation value

    operation _SplitJWZTerm_(generatorIndex : GeneratorIndex, qubits : Qubit[]) : ((Qubit[] => Unit : Adjoint, Controlled), Pauli[], Int)[] {
        // we'd like to apply the single Z term
        // in this case, we need to also provide a list of paulis as the measurement basis
        let ((idxTermType, coeff), idxFermions) = generatorIndex!;

        // create the basis set to return
        mutable total_gates = new Pauli[Length(qubits)];

        // say that the gate at this qubit is a Z
        set total_gates[idxFermions[0]] = PauliZ;

        return [(ApplyPauli(total_gates, _), total_gates, -1)];
    }

    operation _SplitJWZZTerm_(generatorIndex : GeneratorIndex, qubits : Qubit[]) : ((Qubit[] => Unit : Adjoint, Controlled), Pauli[], Int)[] {
        let ((idxTermType, coeff), idxFermions) = generatorIndex!;

        // output array
        mutable total_gates = new Pauli[Length(qubits)];

        // we need to apply a Z at the specified qubits 
        set total_gates[idxFermions[0]] = PauliZ;
        set total_gates[idxFermions[1]] = PauliZ;

        return [(ApplyPauli(total_gates, _), total_gates, 1)];
    }

    operation _SplitJWPQTerm_(term : GeneratorIndex, extraParityQubits : Qubit[], qubits : Qubit[]) :  ((Qubit[] => Unit : Adjoint, Controlled), Pauli[], Int)[] {
        let ((idxTermType, coeff), idxFermions) = term!;

        // output array to hold all the terms
        mutable out_hold = new ((Qubit[] => Unit : Adjoint, Controlled), Pauli[], Int)[0];

        // pull out the qubits that matter
        let qubitsPQ = Subarray(idxFermions[0 .. 1], qubits);

        // pull out the qubits in between
        let qubitsJW = qubits[idxFermions[0] + 1 .. idxFermions[1] - 1];

        // our available operations
        let ops = [[PauliX, PauliX], [PauliY, PauliY]];

        // for both of our ops
        for (idxOp in 0 .. Length(ops) - 1) {
            mutable total_gates = new Pauli[Length(qubits) + Length(extraParityQubits)];
            // we start with our ops XX or YY and continue with ZZZZ...
            // but we only apply these operations to the ends and everything in between
            
            // assign the above ops to be performed
            set total_gates[idxFermions[0]] = ops[idxOp][0];
            set total_gates[idxFermions[1]] = ops[idxOp][1];

            // select the qubits between p/q to have Z applied
            for (qubit_index in idxFermions[0] + 1 .. idxFermions[1] - 1) { 
                set total_gates[qubit_index] = PauliZ;
            }

            // apply Z to the final qubits (the parity checks)
            for (qubit_index in Length(qubits) .. Length(total_gates) - 1) {
                set total_gates[qubit_index] = PauliZ;
            }

            set out_hold = out_hold + [(ApplyPauli(total_gates, _), total_gates, 1)];
        }
        return out_hold;
    }

    operation _SplitPQandPQQRTerm_(generatorIndex : GeneratorIndex, qubits : Qubit[]) : ((Qubit[] => Unit : Adjoint, Controlled), Pauli[], Int)[] {
        let ((idxTermType, coeff), idxFermions) = generatorIndex!;
        // let angle = (1.0 * coeff[0]) * stepSize;
        let qubitQidx = idxFermions[1];
        
        // For all cases, do the same thing:
        // p < r < q (1/4)(1-Z_q)(Z_{r-1,p+1})(X_p X_r + Y_p Y_r) (same as Hermitian conjugate of r < p < q)
        // q < p < r (1/4)(1-Z_q)(Z_{r-1,p+1})(X_p X_r + Y_p Y_r)
        // p < q < r (1/4)(1-Z_q)(Z_{r-1,p+1})(X_p X_r + Y_p Y_r)
        
        // This amounts to applying a PQ term, followed by same PQ term after a CNOT from q to the parity bit.
        if (Length(idxFermions) == 2) {
            let termPR0 = GeneratorIndex((idxTermType, [1.0]), idxFermions);
            return _SplitJWPQTerm_(termPR0, new Qubit[0], qubits);
        }
        else {
            if (idxFermions[0] < qubitQidx && qubitQidx < idxFermions[3]) {
                let termPR1 = GeneratorIndex((idxTermType, [1.0]), [idxFermions[0], idxFermions[3] - 1]);
                mutable to_process = _SplitJWPQTerm_(termPR1, new Qubit[0], Exclude([qubitQidx], qubits));

                // for each gate set returned
                for (gate_set in 0..Length(to_process) - 1) {

                    // unpack the gate set and the paulis used
                    let (given_gate, given_paulis, value) = to_process[gate_set];

                    // create the new array by exluding a qubit
                    // 0, 1, 2, 3, 4, 5, 6, 7
                    // exclude 2 so our output is
                    // z, z, ,  z, z, z, z, z,

                    // our new oracle will first cull unecessary qubits from the original size down to our new size
                    let new_oracle = ApplyToSubregisterCA(given_gate, Exclude([qubitQidx], IntArrayFromRange(0..Length(qubits) - 1)), _);

                    // we also need to make sure that we measure the unaffected qubit normally
                    let new_paulis = given_paulis[0..qubitQidx - 1] + [PauliI] + given_paulis[qubitQidx..Length(given_paulis) - 1];
                    set to_process[gate_set] = (new_oracle, new_paulis, 1);
                }
                return to_process;
            }
            else {
                let termPR1 = GeneratorIndex((idxTermType, [1.0]), [0, idxFermions[3] - idxFermions[0]]);
                mutable to_process = _SplitJWPQTerm_(termPR1, [qubits[qubitQidx]], qubits[idxFermions[0] .. idxFermions[3]]);
                for (gate_set in 0..Length(to_process) - 1) {
                    let (given_gate, given_paulis, value) = to_process[gate_set];

                    // we need to shape our array so that the last qubit is our parity and the first ones are our body
                    let new_oracle = ApplyToSubregisterCA(given_gate, IntArrayFromRange(idxFermions[0]..idxFermions[3]) + [qubitQidx], _);
                    
                    // new pauli strings
                    mutable new_paulis = new Pauli[Length(qubits)];

                    // our Q is definitely a Z
                    set new_paulis[qubitQidx] = PauliZ;

                    // iterate through and make sure to set the pauli array with the right paulis
                    mutable counter = 0;
                    for (pauli_index in idxFermions[0]..idxFermions[3]) {
                        set new_paulis[pauli_index] = given_paulis[counter];
                        set counter = counter + 1;
                    }
                    // let new_paulis = new Pauli[0..] + given_paulis + new Pauli[Length(qubits) - idxFermions[3] - 1];
                    set to_process[gate_set] = (new_oracle, new_paulis, 1);
                }
                return to_process; 
            }
        }
    }

    operation _SplitJW0123Term_(generatorIndex : GeneratorIndex, qubits : Qubit[]) : ((Qubit[] => Unit : Adjoint, Controlled), Pauli[], Int)[] {
        let ((idxTermType, v0123), idxFermions) = generatorIndex!;
        // let angle = stepSize;

        // select the first two qubits 
        let qubitsPQ = Subarray(idxFermions[0 .. 1], qubits);

        // select the second two qubits 
        let qubitsRS = Subarray(idxFermions[2 .. 3], qubits);

        // select the range of qubits in between pq
        let qubitsPQJW = qubits[idxFermions[0] + 1 .. idxFermions[1] - 1];

        // select the range of qubitis in between rs
        let qubitsRSJW = qubits[idxFermions[2] + 1 .. idxFermions[3] - 1];

        // all of the ops we need to do
        let ops = [[PauliX, PauliX, PauliX, PauliX], 
                   [PauliX, PauliX, PauliY, PauliY], 
                   [PauliX, PauliY, PauliX, PauliY], 
                   [PauliY, PauliX, PauliX, PauliY], 
                   [PauliY, PauliY, PauliY, PauliY], 
                   [PauliY, PauliY, PauliX, PauliX], 
                   [PauliY, PauliX, PauliY, PauliX], 
                   [PauliX, PauliY, PauliY, PauliX]];
        
        mutable out_hold = new ((Qubit[] => Unit : Adjoint, Controlled), Pauli[], Int)[0];

        // for each of these operations we need to perform
        for (idxOp in 0 .. Length(ops) - 1) {
            mutable total_gates = new Pauli[Length(qubits)];

            mutable value = 1;

            if (idxOp == 0 || idxOp == 5) {
                set value = -1;
            }
            
            if (IsNotZero(v0123[idxOp % 4])) {               
                // for each gate in the ops list
                for (op_index in 0..Length(ops[idxOp]) - 1) {
                    // set the gate basis to that pauli
                    set total_gates[idxFermions[op_index]] = ops[idxOp][op_index];
                }

                // give the Z terms for the PQJW qubits
                for (qubit_index in idxFermions[0] + 1 .. idxFermions[1] - 1) {
                    set total_gates[qubit_index] = PauliZ;
                }

                // give the Z terms for the RSJW qubits
                for (qubit_index in idxFermions[1] + 1 .. idxFermions[3] - 1) {
                    set total_gates[qubit_index] = PauliZ;
                }

                set out_hold = out_hold + [(ApplyPauli(total_gates, _), total_gates, value)];
            }
        }
        return out_hold;
    }

    // Create a set of unitaries that describes the transformations to be made on qubits given a specific generatorIndex
    operation CreatePauliSet (generatorIndex : GeneratorIndex, qubits : Qubit[]) : ((Qubit[] => Unit : Adjoint, Controlled), Pauli[], Int)[] {
        let ((idxTermType, idxDoubles), idxFermions) = generatorIndex!;
        let termType = idxTermType[0];
        
        if (termType == 0) {
            // Message($"A term of type 0 is being used");
            return _SplitJWZTerm_(generatorIndex, qubits);
        }
        elif (termType == 1) {
            // Message($"A term of type 1 is being used");
            return _SplitJWZZTerm_(generatorIndex, qubits);
        }
        elif (termType == 2) {
            // Message($"A term of type 2 is being used");
            return _SplitPQandPQQRTerm_(generatorIndex, qubits);
        }
        elif (termType == 3) {
            // Message($"A term of type 3 is being used");
            return _SplitJW0123Term_(generatorIndex, qubits);
        }
        else {
            Message($"OTHER IS INVOLVED");
            return new ((Qubit[] => Unit : Adjoint, Controlled), Pauli[], Int)[0];
        }
    } 
}


