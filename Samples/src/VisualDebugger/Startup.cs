// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.DependencyInjection;

namespace Microsoft.Quantum.Samples.VisualDebugger
{
    /// <summary>
    /// Configures the ASP.NET Core web host. This class is used when the web host is created in
    /// <see cref="VisualDebugger"/>.
    /// </summary>
    internal class Startup
    {
        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
            services.AddSignalR();
            services.AddMvc();
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IHostingEnvironment env) =>
            app
                .UseDefaultFiles()
                .UseStaticFiles()
                .UseDeveloperExceptionPage()
                .UseMvc()
                .UseSignalR(routes => routes.MapHub<VisualDebuggerHub>("/events"));
    }
}
