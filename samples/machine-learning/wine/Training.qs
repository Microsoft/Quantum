// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Samples {
    open Microsoft.Quantum.Random;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.MachineLearning;
    open Microsoft.Quantum.MachineLearning.Datasets as Datasets;
    open Microsoft.Quantum.Math;

    function DefaultSchedule(samples : LabeledSample[]) : SamplingSchedule {
        return SamplingSchedule([
            0..Length(samples) - 1
        ]);
    }

    function ClassifierStructure() : ControlledRotation[] {
        return CombinedStructure([
            LocalRotationsLayer(4, PauliZ),
            LocalRotationsLayer(4, PauliX),
            CyclicEntanglingLayer(4, PauliX, 1),
            PartialRotationsLayer([3], PauliX)
        ]);
    }

    operation SampleSingleParameter() : Double {
        return PI() * (DrawRandomDouble(0.0, 1.0) - 1.0);
    }

    operation SampleParametersForSequence(structure : ControlledRotation[]) : Double[] {
        return ForEach(SampleSingleParameter, ConstantArray(Length(structure), ()));
    }

    operation SampleInitialParameters(nInitialParameterSets : Int, structure : ControlledRotation[]) : Double[][] {
        return ForEach(SampleParametersForSequence, ConstantArray(nInitialParameterSets, structure));
    }

    operation TrainWineModel() : (Double[], Double) {
        // Get the first 143 samples to use as training data.
        let samples = (Datasets.WineData())[...142];
        let structure = ClassifierStructure();
        // Sample a random set of parameters.
        let initialParameters = SampleInitialParameters(16, structure);

        Message($"Ready to train using {structure}.");
        let (optimizedModel, nMisses) = TrainSequentialClassifier(
            Mapped(
                SequentialModel(structure, _, 0.0),
                initialParameters
            ),
            samples,
            DefaultTrainingOptions()
                w/ LearningRate <- 0.4
                w/ MinibatchSize <- 2
                w/ Tolerance <- 0.01
                w/ NMeasurements <- 100000
                w/ MaxEpochs <- 10
                w/ VerboseMessage <- Message,
            DefaultSchedule(samples),
            DefaultSchedule(samples)
        );
        Message($"Training complete, found optimal parameters and bias: {optimizedModel::Parameters}, {optimizedModel::Bias}");
        return (optimizedModel::Parameters, optimizedModel::Bias);
    }

    operation ValidateWineModel(
        parameters : Double[],
        bias : Double
    ) : Int {
        // Get the remaining samples to use as validation data.
        let samples = (Datasets.WineData())[143...];
        let tolerance = 0.005;
        let nMeasurements = 10000;
        let results = ValidateSequentialClassifier(
            SequentialModel(ClassifierStructure(), parameters, bias),
            samples,
            tolerance,
            nMeasurements,
            DefaultSchedule(samples)
        );
        return results::NMisclassifications;
    }

}
