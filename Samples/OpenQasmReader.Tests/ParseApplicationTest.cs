﻿// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
using System.Collections.Generic;
using System.IO;
using System.Text;
using Xunit;

namespace Microsoft.Quantum.Samples.OpenQasmReader.Tests
{
    public class ParseApplicationTest
    {
        [Fact]
        public void ParseHeaderTest()
        {
            var input = "OPENQASM 2.0;";
            using (var stream = new StringReader(input))
            {
                var enumerator = Parser.Tokenizer(stream).GetEnumerator();

                var cRegs = new Dictionary<string, int>();
                var qRegs = new Dictionary<string, int>();
                var inside = new StringBuilder();
                var outside = new StringBuilder();
                var conventionalMeasured = new List<string>();
                Parser.ParseApplication(enumerator, cRegs, qRegs, "path", inside, outside, conventionalMeasured);

                //Expecting to end on the ';', so next loop can pick the next token
                Assert.Equal(";", enumerator.Current);
            }
        }

        [Fact]
        public void ParseQRegTest()
        {
            var input = "qreg q[3];";
            using (var stream = new StringReader(input))
            {
                var enumerator = Parser.Tokenizer(stream).GetEnumerator();

                var cRegs = new Dictionary<string, int>();
                var qRegs = new Dictionary<string, int>();
                var inside = new StringBuilder();
                var outside = new StringBuilder();
                var conventionalMeasured = new List<string>();
                Parser.ParseApplication(enumerator, cRegs, qRegs, "path", inside, outside, conventionalMeasured);

                //Expecting to end on the ';', so next loop can pick the next token
                Assert.Equal(";", enumerator.Current);
                //No traditional registers
                Assert.Equal(new string[0], cRegs.Keys);
                Assert.Equal(new int[0], cRegs.Values);
                //we now have quantum Registers
                Assert.Equal(new string[] { "q" }, qRegs.Keys);
                Assert.Equal(new int[] { 3 }, qRegs.Values);
                //No output
                Assert.Equal(string.Empty, inside.ToString());
                Assert.Equal(string.Empty, outside.ToString());
            }
        }

        [Fact]
        public void ParseCRegTest()
        {
            var input = "creg c[3];";
            using (var stream = new StringReader(input))
            {
                var enumerator = Parser.Tokenizer(stream).GetEnumerator();

                var cRegs = new Dictionary<string, int>();
                var qRegs = new Dictionary<string, int>();
                var inside = new StringBuilder();
                var outside = new StringBuilder();
                var conventionalMeasured = new List<string>();
                Parser.ParseApplication(enumerator, cRegs, qRegs, "path", inside, outside, conventionalMeasured);

                //Expecting to end on the ';', so next loop can pick the next token
                Assert.Equal(";", enumerator.Current);
                //we now have traditional cRegisters
                Assert.Equal(new string[] { "c" }, cRegs.Keys);
                Assert.Equal(new int[] { 3 }, cRegs.Values);
                //No quantum registers
                Assert.Equal(new string[0], qRegs.Keys);
                Assert.Equal(new int[0], qRegs.Values);
                //No output
                Assert.Equal(string.Empty, inside.ToString());
                Assert.Equal(string.Empty, outside.ToString());
            }
        }

        [Fact]
        public void ParseGateDefintionTest()
        {
            var input = "gate mygate q { H q;}";

            using (var stream = new StringReader(input))
            {
                var enumerator = Parser.Tokenizer(stream).GetEnumerator();

                var cRegs = new Dictionary<string, int>();
                var qRegs = new Dictionary<string, int>();
                var inside = new StringBuilder();
                var outside = new StringBuilder();
                var conventionalMeasured = new List<string>();
                Parser.ParseApplication(enumerator, cRegs, qRegs, "path", inside, outside, conventionalMeasured);

                //Expecting to end on the '}', so next loop can pick the next token
                Assert.Equal("}", enumerator.Current);
                //no traditional cRegisters
                Assert.Equal(new string[0], cRegs.Keys);
                Assert.Equal(new int[0], cRegs.Values);
                //No quantum registers
                Assert.Equal(new string[0], qRegs.Keys);
                Assert.Equal(new int[0], qRegs.Values);
                //No output within the method
                Assert.Equal(string.Empty, inside.ToString());

                //Expected operation
                Assert.Equal("operation Mygate(q:Qubit):(){body{H(q);}}",
                    outside.ToString().Trim()
                        .Replace("\n", string.Empty)
                        .Replace("\r", string.Empty)
                        .Replace(Parser.INDENTED, string.Empty)
                        .Replace("  ", string.Empty));
            }
        }

        [Fact]
        public void ParseIfDefintionTest()
        {
            var input = "if (c0 == 1) z q[2];";

            using (var stream = new StringReader(input))
            {
                var enumerator = Parser.Tokenizer(stream).GetEnumerator();

                var cRegs = new Dictionary<string, int>();
                var qRegs = new Dictionary<string, int>();
                var inside = new StringBuilder();
                var outside = new StringBuilder();
                var conventionalMeasured = new List<string>();
                Parser.ParseApplication(enumerator, cRegs, qRegs, "path", inside, outside, conventionalMeasured);

                //Expecting to end on the ';', so next loop can pick the next token
                Assert.Equal(";", enumerator.Current);
                //no traditional cRegisters
                Assert.Equal(new string[0], cRegs.Keys);
                Assert.Equal(new int[0], cRegs.Values);
                //No quantum registers
                Assert.Equal(new string[0], qRegs.Keys);
                Assert.Equal(new int[0], qRegs.Values);
                //expected internals
                Assert.Equal("if(c0==1){Z(q[2]);}", inside.ToString().Trim()
                        .Replace("\n", string.Empty)
                        .Replace("\r", string.Empty)
                        .Replace(Parser.INDENTED, string.Empty)
                        .Replace("  ", string.Empty));

                //No outside generation
                Assert.Equal(string.Empty, outside.ToString());
            }
        }

        [Fact]
        public void ParseMeasureDefintionTest()
        {
            var input = "measure q[0] -> c0[0];";

            using (var stream = new StringReader(input))
            {
                var enumerator = Parser.Tokenizer(stream).GetEnumerator();

                var cRegs = new Dictionary<string, int>();
                var qRegs = new Dictionary<string, int>();
                var inside = new StringBuilder();
                var outside = new StringBuilder();
                var conventionalMeasured = new List<string>();
                Parser.ParseApplication(enumerator, cRegs, qRegs, "path", inside, outside, conventionalMeasured);

                //Expecting to end on the ';', so next loop can pick the next token
                Assert.Equal(";", enumerator.Current);
                //no traditional cRegisters
                Assert.Equal(new string[0], cRegs.Keys);
                Assert.Equal(new int[0], cRegs.Values);
                //No quantum registers
                Assert.Equal(new string[0], qRegs.Keys);
                Assert.Equal(new int[0], qRegs.Values);

                //q[0] has now been measured, so c0[0] has output
                Assert.Equal(new string[] { "c0[0]" }, conventionalMeasured);

                //expected internals
                Assert.Equal("set c0[0] = M(q[0]);", inside.ToString().Trim()
                        .Replace("\n", string.Empty)
                        .Replace("\r", string.Empty)
                        .Replace(Parser.INDENTED, string.Empty)
                        .Replace("  ", string.Empty));

                //No outside generation
                Assert.Equal(string.Empty, outside.ToString());
            }
        }
        
    }
}