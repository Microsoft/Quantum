﻿// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
using System;
using System.IO;
using System.Reflection;
using System.Resources;
using System.Text;
using System.Text.RegularExpressions;
using Xunit;

namespace Microsoft.Quantum.Samples.OpenQasmReader.Tests
{
    public class End2EndTest
    {
        const string SOURCE_NAMESPACE = "Microsoft.Quantum.Samples.OpenQasmReader.Tests.TestFunctions";
        const string TARGET_NAMESPACE = "Microsoft.Quantum.Samples.OpenQasmReader.Tests.Validate";

        [Fact]
        public void HadamardConversionTest() => TestConversion("Hadamard.qs", $"{SOURCE_NAMESPACE}.Hadamard.qasm", $"{TARGET_NAMESPACE}.Hadamard.qs");

        [Fact]
        public void CNotConversionTest() => TestConversion("CNot.qs", $"{SOURCE_NAMESPACE}.CNot.qasm", $"{TARGET_NAMESPACE}.CNot.qs");

        [Fact]
        public void GatesConversionTest() => TestConversion("Gates.qs", $"{SOURCE_NAMESPACE}.Gates.qasm", $"{TARGET_NAMESPACE}.Gates.qs");

        private static void TestConversion(string name, string inputResourceName, string expectedResourceName)
        {
            var input = ReadResource(inputResourceName); ;
            var expected = ReadResource(expectedResourceName); ;

            var inputFile = Path.Combine(Path.GetTempPath(), name);
            try
            {
                //Write OpenQuasm program 
                File.WriteAllText(inputFile, input);

                //Transform
                var result = Parser.ConvertQasmFile(TARGET_NAMESPACE, inputFile);
                
                //Reformat result, so they can be compared (unix/windows, layout differences, and copyright headers);
                expected = Regex.Replace(expected, @"\s+", " ").Trim().Trim(new char[] { '\uFEFF', '\u200B' });
                result = COPYRIGHTHEADER.Replace("\n", Environment.NewLine) + result;
                result = Regex.Replace(result, @"\s+", " ").Trim().Trim(new char[] { '\uFEFF', '\u200B' }); ;

                Assert.Equal(expected, result);
            }
            finally
            {
                if (File.Exists(inputFile))
                {
                    File.Delete(inputFile);
                }
            }
        }

        private static string ReadResource(string resourceName)
        {
            var assembly = Assembly.GetExecutingAssembly();
            using (var stream = assembly.GetManifestResourceStream(resourceName))
            {
                if (stream == null)
                {
                    throw new Exception($"Resource {resourceName} not found in {assembly.FullName}.  Valid resources are: {String.Join(", ", assembly.GetManifestResourceNames())}.");
                }
                using (var reader = new StreamReader(stream))
                {
                    return reader.ReadToEnd();
                }
            }
        }

        private const string COPYRIGHTHEADER = "// Copyright (c) Microsoft Corporation. All rights reserved.\n// Licensed under the MIT License.\n";
    }
}
