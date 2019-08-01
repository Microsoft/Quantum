// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.AspNetCore;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.SignalR;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace vis_sim
{
    public partial class VisualizationSimulator
    {
        internal readonly QuantumSimulator underlyingSimulator;
        private readonly IWebHost host;

        private readonly IHubContext<VisualizationHub> context;
        private readonly AdvanceEvent advance;

        private readonly ManualResetEvent readyToProceed = new ManualResetEvent(true);

        private readonly Stack<IApplyData> operations = new Stack<IApplyData>();

        public VisualizationSimulator()
        {
            underlyingSimulator = new QuantumSimulator();

            host = WebHost
                .CreateDefaultBuilder()
                .UseStartup<Startup>()
                .ConfigureServices(services => {
                    // Register ourselves as a service so that the different
                    // hubs and controllers can use us through DI.
                    services.AddSingleton(typeof(VisualizationSimulator), this);
                })
                .UseUrls("http://localhost:5000")
                .UseKestrel()
                .Build();
            var serverThread = new Thread(
                () => host.Run()
            );
            serverThread.Start();

            context = GetService<IHubContext<VisualizationHub>>();
            advance = GetService<AdvanceEvent>();

            underlyingSimulator.OnOperationStart += OnOperationStartHandler;
            underlyingSimulator.OnOperationEnd += OnOperationEndHandler;
        }

        public async Task Run(Func<IOperationFactory, Task<QVoid>> operation)
        {
            await UserInput();
            await operation(underlyingSimulator);
        }

        private T GetService<T>() => ((T) host.Services.GetService(typeof(T)));

        private Task BroadcastAsync(string method, object arg) =>
            context.Clients.All.SendAsync(method, arg);

        private Task BroadcastAsync(string method, object arg1, object arg2) =>
            context.Clients.All.SendAsync(method, arg1, arg2);

        private Task BroadcastAsync(string method, object arg1, object arg2, object arg3) =>
            context.Clients.All.SendAsync(method, arg1, arg2, arg3);

        private async Task UserInput()
        {
            await Task.Run(() => {
                advance.WaitForUser();
            });
        }

        private async Task AnnounceOperation(string operationName, object arguments = null, object result = null)
        {
            await BroadcastAsync("operationCalled", operationName, arguments ?? QVoid.Instance, result ?? QVoid.Instance);
            await UserInput();
        }

        private void OnOperationStartHandler(ICallable operation, IApplyData arguments) => operations.Push(arguments);

        private void OnOperationEndHandler(ICallable operation, IApplyData result)
        {
            var qubits = operations.Pop().Qubits?.Select(q => q.Id).ToArray();
            AnnounceOperation(GetOperationDisplayName(operation), qubits, result.Value).Wait();
        }

        private static string GetOperationDisplayName(ICallable operation)
        {
            switch (operation.Variant)
            {
                case OperationFunctor.Body: return operation.Name;
                case OperationFunctor.Adjoint: return $"Adjoint {operation.Name}";
                case OperationFunctor.Controlled: return $"Controlled {operation.Name}";
                case OperationFunctor.ControlledAdjoint: return $"Controlled Adjoint {operation.Name}";
                default: throw new ArgumentException("Invalid operation variant", nameof(operation));
            }
        }
    }
}
