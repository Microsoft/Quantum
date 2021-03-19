
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;
using System;
using System.IO;
using System.Linq;
using System.Text.Json;
using System.Runtime.InteropServices;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Diagnostics;
using static System.Math;

namespace Microsoft.Quantum.Samples
{
    using Microsoft.Quantum.MachineLearning;

    class Program
    {
        static async Task Main(string[] args)
        {
            // Next, we initialize a full state-vector simulator as our target machine.
            using var targetMachine = new QuantumSimulator().WithTimestamps();

            // Once we initialized our target machine,
            // we can then use that target machine to train a QCC classifier.
            var (optimizedParameters, optimizedBias) = await TrainWineModel.Run(
                targetMachine
            );

            // After training, we can use the validation data to test the accuracy
            // of our new classifier.
            var testMisses = await ValidateWineModel.Run(
                targetMachine,
                optimizedParameters,
                optimizedBias
            );
            System.Console.WriteLine($"Observed {testMisses} misclassifications.");
        }
    }

    public static class SimulatorExtensions
    {
        public static QuantumSimulator WithTimestamps(this QuantumSimulator sim)
        {
            var stopwatch = new Stopwatch();
            stopwatch.Start();
            var last = stopwatch.Elapsed;
            sim.DisableLogToConsole();
            sim.OnLog += (message) =>
            {
                var now = stopwatch.Elapsed;
                Console.WriteLine($"[{now} +{now - last}] {message}");
                last = now;
            };
            return sim;
        }
    }
}
