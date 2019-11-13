namespace Microsoft.Quantum.Samples {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.MachineLearning;
    open Microsoft.Quantum.Math;

    function WithOffset(offset : Double, sample : Double[]) : Double[] {
        return Mapped(TimesD(offset, _), sample);
    }

    function WithProductKernel(scale : Double, sample : Double[]) : Double[] {
        return sample + [scale * Fold(TimesD, 1.0, sample)];
    }

    function Preprocessed(samples : Double[][]) : Double[][] {
        let offset = 0.75;
        let scale = 1.0;

        return Mapped(
            Compose(
                WithOffset(offset, _),
                WithProductKernel(scale, _)
            ),
            samples
        );
    }

    function DefaultSchedule(samples : Double[][]) : SamplingSchedule {
        return SamplingSchedule([
            0..Length(samples) - 1
        ]);
    }

    // FIXME: This needs to return a GateSequence value, but that requires adapting
    //        TrainQcccSequential.
    function ClassifierStructure() : GateSequence {
        let (x, y, z) = (1, 2, 3);
        return GateSequence([
            ControlledRotation(GateSpan(0, new Int[0]), PauliX, 4),
            ControlledRotation(GateSpan(0, new Int[0]), PauliZ, 5),
            ControlledRotation(GateSpan(1, new Int[0]), PauliX, 6),
            ControlledRotation(GateSpan(1, new Int[0]), PauliZ, 7),
            ControlledRotation(GateSpan(0, [1]), PauliX, 0),
            ControlledRotation(GateSpan(1, [0]), PauliX, 1),
            ControlledRotation(GateSpan(1, new Int[0]), PauliZ, 2),
            ControlledRotation(GateSpan(1, new Int[0]), PauliX, 3)
        ]);
    }

    operation TrainHalfMoonModel(
        trainingVectors : Double[][],
        trainingLabels : Int[],
        initialParameters : Double[][]
    ) : (Double[], Double) {
        let samples = Mapped(
            LabeledSample,
            Zip(Preprocessed(trainingVectors), trainingLabels)
        );
        let nQubits = 2;
        let learningRate = 0.1;
        let minibatchSize = 15;
        let tolerance = 0.005;
        let nMeasurements = 10000;
        let maxEpochs = 16;
        Message("Ready to train.");
        let (optimizedParameters, optimialBias) = TrainSequentialClassifier(
            nQubits,
            ClassifierStructure(),
            initialParameters,
            samples,
            DefaultSchedule(trainingVectors),
            DefaultSchedule(trainingVectors),
            learningRate, tolerance, minibatchSize,
            maxEpochs,
            nMeasurements
        );
        Message($"Training complete, found optimal parameters: {optimizedParameters}");
        return (optimizedParameters, optimialBias);
    }

    operation ValidateHalfMoonModel(
        validationVectors : Double[][],
        validationLabels : Int[],
        parameters : Double[],
        bias : Double
    ) : Int {
        let samples = Mapped(
            LabeledSample,
            Zip(Preprocessed(validationVectors), validationLabels)
        );
        let nQubits = 2;
        let tolerance = 0.005;
        let nMeasurements = 10000;
        let results = ValidateModel(
            tolerance,
            nQubits,
            samples,
            DefaultSchedule(validationVectors),
            ClassifierStructure(),
            parameters,
            bias,
            nMeasurements
        );
        return results::NMisclassifications;
    }

}
