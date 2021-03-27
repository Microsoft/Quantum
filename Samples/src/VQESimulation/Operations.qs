// MAIN VARIATIONAL QUANTUM EIGENSOLVER CODE
// AUTHOR: CHRISTOPHER KANG, UNIVERSITY OF WASHINGTON
// 490Q, KRYSTA SVORE, WI 2019

// This file defines critical methods for VQE simulation. 
namespace VQE
{
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Extensions.Math;
    open Microsoft.Quantum.Extensions.Testing;
    open Microsoft.Quantum.Extensions.Convert;
    open Microsoft.Quantum.Chemistry;
    open Microsoft.Quantum.Chemistry.JordanWigner; 
    open MultiUnitary;

    operation create_generator (qSharpData : JordanWignerEncodingData) : (GeneratorSystem, Int) {
        
        // Depack the data from the JWEncoding
        // We really only need the fermionic info
        let (nSpinOrbitals, data, statePrepData, energyShift) = qSharpData!;

        // we convert the h terms into a generator system (Int, Int -> GeneratorIndex)
        // essentially, we make it so that the GeneratorIndexes are indexed, 
        // and that the phase + the targets are in the GeneratorIndex format
        let generatorSystem = JordanWignerGeneratorSystem(data);

        return (generatorSystem, nSpinOrbitals);
    }

    operation Simulate_Variational (data : JordanWignerEncodingData, moe : Double, input: JordanWignerInputState[]) : Double {
        // simulate a system given JW data, a precision to search over input parameter ansatz, and 
        // a (currently ignored) margin of error to use when approximating the expectation value
        //Message("BEGINNING SIMULATION");

        let (nSpinOrbitals, fermionTermData, statePrepData, energyOffset) = data!;

        // Create the main data source (EvolutionGenerator) with which to feed the VQE
        // This contains the data needed to construct specific terms
        let (ham_terms, nOrbitals) = create_generator(data);

        //Message($"{nOrbitals}");

        // start ground energy, phase, and index of the matrix
        mutable energy = 0.0;

        // we will use nOrbitals number of qubits. Each qubit, therefore, represents an orbital
        using (testQ = Qubit[nOrbitals]) {
            //let initial_oracle = PrepareTrialState(statePrepData, _);
            let initial_oracle = PrepareTrialState(input, _);
            
            // create an energy estimate, making sure to include the offset
            set energy = SumExpectedValues(initial_oracle, ham_terms, testQ, moe) + energyOffset;
        }
        return energy;
    }

    operation Simulate (data : JordanWignerEncodingData, moe : Double, runs : Int) : Double[][] {
        // Simulate a system given JW data and a margin of error to use 
        // when approximating the expectation value. Note the margin of error caps the # of runs to 50,
        // (so each unitary only has 50 runs to estimate the expectation value) to prevent 
        // exponential numbers of runs.
        // This method is allows the direct simulation of a specific ground state energy, provided 
        // the Hamiltonian data includes the info
        // Message("BEGINNING SIMULATION");

        let (nSpinOrbitals, fermionTermData, statePrepData, energyOffset) = data!;

        // output matrix with (precision, energy level) pairs
        mutable out_val = new Double[][0];

        // Create the main data source (EvolutionGenerator) with which to feed the VQE
        // This contains the data needed to construct specific terms
        let (ham_terms, nOrbitals) = create_generator(data);

        Message($"{nOrbitals}");

        // start ground energy, phase, and index of the matrix
        // mutable ground_energy = 1000.0;
        // mutable ground_phase = 3.0;
        mutable index = 0;

        // we will use nOrbitals number of qubits. Each qubit, therefore, represents an orbital
        using (testQ = Qubit[nOrbitals]) {
            mutable run_num = 0;
            repeat {
                mutable temp_out_array = new Double[][1];
                // Message($"Testing phase: {run_num}");

                // Message($"{energyOffset}");

                // create the oracle that creates the initial state
                // let initial_oracle = NoOp<Qubit[]>;
                let initial_oracle = PrepareTrialState(statePrepData, _);
                // let initial_oracle = prepareStateHelper(initCoeffs, _);
                
                // create an energy estimate, making sure to include the offset
                let discovered_energy = SumExpectedValues(initial_oracle, ham_terms, testQ, moe) + energyOffset;
                
                // set the specific row to have the initial state given + the energy prediction
                set temp_out_array[0] = [ToDouble(run_num), discovered_energy];

                // add it to our output array
                set out_val = out_val + temp_out_array;

                // if the energy found is lower than the previous low
                // if (discovered_energy < ground_energy) {

                //     // reset the low energy amount + reset the low energy parameter
                //     set ground_energy = discovered_energy;
                //     set ground_phase = ToDouble(run_num);
                // }

                // Message($"ENERGY FOUND: {discovered_energy}");

                // increment the index for the output matrix
                set index = index + 1;

                // increase the run number
                set run_num = run_num + 1;
            } until (run_num >= runs)
            fixup {

            }
        }
        // Message($"Ground energy: {ground_energy}");
        // Message($"Ground state: {ground_phase}");
        return out_val;
    }

    // help that allows for the use of PrepareArbitraryState where oracle is expected
    operation prepareStateHelper (coeffs : ComplexPolar[], qs : Qubit[]) : Unit {
        PrepareArbitraryState(coeffs, BigEndian(qs));
    }

    operation SumExpectedValues(initial_oracle : (Qubit[] => Unit), 
                                HamiltonianGates : GeneratorSystem, 
                                ancilla : Qubit[], moe : Double) : Double {
        // Sum the total expected values over all terms of a hamiltonian 
        // with a given oracle that produces the starting state

        // total expectation value found 
        mutable total = 0.0;

        // we need to unpack the evolutionSet to use and the generator
        // let (evolutionSet, generator) = (HamiltonianGates)!;

        // we extract the total number of terms and the indexing function
        let (num_of_terms, jw_term_indexer) = (HamiltonianGates)!;

        // we now iterate through each of the terms
        for (i in 0..num_of_terms - 1) {
            // Message($"Completed term: {i + 1} / {num_of_terms}. Current total: {total}");
            // and take the specified term (which is of type GeneratorIndex)
            let jw_term = jw_term_indexer(i);

            // for each JW term create the individual gates
            let gate_basis_pairs = CreatePauliSet(jw_term, ancilla);

            // for each gate combo we have
            for (gate_combo in 0..Length(gate_basis_pairs) - 1) {

                // extract the gate to evaluate and the basis to use
                let (gate_to_evaluate, basis, value) = gate_basis_pairs[gate_combo];

                // also get the weight
                let ((gate_keys, weight), targets) = jw_term!;

                // multiply the expected value by the weight
                set total = total + weight[0] * FindExpectedValue(initial_oracle, gate_to_evaluate, basis, ancilla, moe);
            }
        }
        return total;
    }

    operation FindExpectedValue(InitialStateOracle : (Qubit[] => Unit), 
                                gate : (Qubit[] => Unit), measure_basis : Pauli[],
                                ancilla : Qubit[], moe : Double) : Double {
        // repeatedly measures an operator until it's expected value is predicted within a 
        // margin of error! 

        // confidence with which to produce intervals. 1.96 for 95% confidence
        let Z_SCORE = 1.96;

        // value to be returned 
        mutable out_val = -10.0;
        
        // running total of "One"s measured
        mutable run_sum = 0.0;

        // total runs
        mutable total_runs = 0.0;

        // current unpredictability of the estimate
        mutable error_term = 1.0;

        repeat {
            for (i in 0..10) {
                // run a single iteration and see if the output is a one
                if (RunSingleIteration(InitialStateOracle, gate, measure_basis, ancilla)) {
                    // We have measured a "One"
                    set run_sum = run_sum + 1.0;
                }
                set total_runs = total_runs + 1.0;
            }

            // recreate the probability distribution
            set out_val = run_sum / total_runs;

            // calculate the current margin of error
            set error_term = MarginOfError(out_val, total_runs, Z_SCORE);
            // currently, we end when our total_runs exceeds 50
        } until (error_term < moe || total_runs >= 50.0)
        fixup {}

        // Recognize that this probability is the probability we have achieved a one
        // thus, we can obtain the expected value with this formula
        // P(0) * 1 + P(1) * -1 = (1-P(1)) * 1 - P(1) = 1 - 2 * P(1)
        return 1.0 - 2.0 * out_val;
    }

    function MarginOfError(probability : Double, runs : Double, Z_SCORE : Double) : Double {
        // follows the information found on
        // "Confidence Interval for a Proportion in One Sample"
        return Z_SCORE * Sqrt(probability * (1.0 - probability) / runs);
    }

    operation RunSingleIteration(InitialStateOracle : (Qubit[] => Unit),
                                 MysteryGate : (Qubit[] => Unit), basis : Pauli[], ancilla : Qubit[]) : Bool {
        // given an oracle to create an arbitrary state, 
        // let us identify the expecatation value of the state with an arbitrary gate
        // and the gate's basis 

        // prepare the sample eigenstate
        InitialStateOracle(ancilla);

        // apply the gate that we want to estimate the expected value of
        MysteryGate(ancilla);

        // return true if the output value is one; false if the output value is zero
        // when we have true, we have measured an eigenvalue of -1; false is +1
        let out_val = Measure(basis, ancilla) == One ? true | false;

        // reset the ancilla so that it can be used immediately after
        ResetAll(ancilla);

        return out_val;
    }
}
