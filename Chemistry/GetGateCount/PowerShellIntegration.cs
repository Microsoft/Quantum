﻿// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

// This loads a Hamiltonian from file and performs gate estimates of a
// - Jordan-Wigner Trotter step
// - Jordan-Wigner Qubitization iterate

#region Using Statements
// We will need several different libraries in this sample.
// Here, we expose these libraries to our program using the
// C# "using" statement, similar to the Q# "open" statement.

// The System namespace provides a number of useful built-in
// types and methods that we'll use throughout this sample.
using System;

// The System.Diagnostics namespace provides us with the
// Stopwatch class, which is quite useful for measuring
// how long each gate counting run takes.
using System.Diagnostics;

// The System.Collections.Generic library provides many different
// utilities for working with collections such as lists and dictionaries.
using System.Collections.Generic;

// We use the logging library provided with .NET Core to handle output
// in a robust way that makes it easy to turn on and off different messages.
using Microsoft.Extensions.Logging;

// Finally, we use the Mono.Options and System.Management.Automation
// libraries to make it easy to use this sample from the command line.
using Mono.Options;
using System.Management.Automation;

#endregion

namespace Microsoft.Quantum.Chemistry.Samples
{

    #region PowerShell Integration
    // In addition to providing the gate count sample as a command-line program,
    // we can also integrate gate counting into PowerShell, making it easier to
    // analyze gate counts for a variety of different integral data files.

    // To integrate with PowerShell, we define a class that inherits from PSCmdlet.
    // This new class will be exposed in PowerShell as the Get-GateCount command.
    [Cmdlet(VerbsCommon.Get, "GateCount")]

    // We can specify the output type, so that PowerShell can offer tab completion
    // and fancy formatting on the results of running Get-GateCount.
    [OutputType(typeof(GateCountResults))]
    public class GetGateCount : PSCmdlet
    {

        // Command-line options to Get-GateCount are defined as properties of the new
        // cmdlet, annotated by Parameter attributes.
        [Parameter(
            Position = 0,
            Mandatory = false,
            ValueFromPipeline = true
        )]
        public string Path { get; set; } =
            // We can specify default values for command-line arguments
            // as the initial values of properties.
            @"..\IntegralData\Liquid\h2s_sto6g_22.dat";

        [Parameter(Position = 1)]
        // By using an enum as a property type, PowerShell will provide tab completion
        // for the valid values of the enumeration.
        public IntegralDataFormat Format { get; set; } = IntegralDataFormat.Liquid;
        
        [Parameter(Position = 2)]
        // We can also define switches to enable or disable different features
        // of our gate counting command.
        public SwitchParameter RunTrotterStep { get; set; } = true;
        
        [Parameter(Position = 3)]
        public SwitchParameter RunMinQubitQubitizationStep { get; set; } = true;

        [Parameter(Position = 4)]
        public SwitchParameter RunMinTCountQubitizationStep { get; set; } = true;

        [Parameter(Position = 5)]
        public string LogPath { get; set; } = null;
        
        public List<HamiltonianSimulationConfig> config
        {
            get
            {
                return Program.MakeConfig(RunTrotterStep, RunMinQubitQubitizationStep, RunMinTCountQubitizationStep);
            }
        }

        // The last bit of metadata we might want to specify is
        // what parts of the output are shown by default.
        // Since the entire CSV outputs from the trace simulator
        // are included in the output, we'll show everything but
        // the giant tables by default.
        // Those tables will still be there, though, just not printed
        // to the screen unless a user explicitly asks for them.
        private PSMemberSet psStandardMembers = new PSMemberSet(
            "PSStandardMembers",
            new List<PSMemberInfo>
            {
                new PSPropertySet(
                    "DefaultDisplayPropertySet",
                    new List<string>
                    {
                        "IntegralDataPath",
                        "HamiltonianName",
                        "SpinOrbitals",
                        "Method",
                        "TCount",
                        "RotationsCount",
                        "CNOTCount",
                        "ElapsedMilliseconds"
                    }
                )
            }
            );

        protected override void BeginProcessing()
        {
            Logging.LogPath = LogPath;
        }

        // The actual logic of the PowerShell command is implemented by overriding the
        // ProcessRecord method.
        // This method gets called once for each object passed to our command.
        // In this case, we specified that file paths are the input that we'll grab off
        // the pipeline, so this method will get called once for each different integral
        // data file.
        protected override void ProcessRecord()
        {
            foreach (var path in this.GetResolvedProviderPathFromPSPath(Path, out var provider))
            {
                // We can run the same method as in the traditional command
                // line program.
                var gateCountResults = Program.RunGateCount(path, Format, config).Result;
                
                foreach(var result in gateCountResults)
                {
                    var psObj = PSObject.AsPSObject(result);
                    psObj.Members.Add(psStandardMembers);
                    WriteObject(psObj);
                }
            }
        }
        
    }

    #endregion

}

