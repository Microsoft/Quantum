# Start from the IQ# base image. The definition for this image can be found at
# https://github.com/microsoft/iqsharp/blob/main/images/iqsharp-base/Dockerfile.
# As per Binder documentation, we choose to use an SHA sum here instead of a
# tag.
FROM mcr.microsoft.com/quantum/iqsharp-base:0.15.210425802-alpha

# Mark that this Dockerfile is used with the samples repository.
ENV IQSHARP_HOSTING_ENV=SAMPLES_DOCKERFILE

# We need to do a few additional things as root here.
USER root

# Install additional system packages from apt.
RUN apt-get -y update && \
    apt-get -y install \
               # For the Python interoperability sample, we require QuTiP,
               # which in turn requires gcc's C++ support.
               g++ \
               # The version of Matplotlib we use also needs a couple header
               # packages.
               pkg-config \
               libfreetype6-dev \
               libpng-dev \
               # iqsharp-base currently ships with .NET Core SDK 3.1, but
               # we need .NET 5.0 to run dotnet-interactive.
               dotnet-sdk-5.0 && \
    # As per https://github.com/NuGet/Announcements/issues/49,
    # we also need to update the ca-certificates package
    # to use nuget restore from .NET 5.0.
    # This requries enabling debian-unstable, so we do so as a
    # separate command.
    cp /etc/apt/sources.list /etc/apt/sources.list.backup && \
    echo "deb https://deb.debian.org/debian unstable main" >> /etc/apt/sources.list && \
    apt-get -y update && \
    apt-get -y install ca-certificates=20210119 && \
    mv /etc/apt/sources.list.backup /etc/apt/sources.list && \
    apt-get clean && rm -rf /var/lib/apt/lists/

# For the chemistry samples, we'll need PowerShell to be
# installed. It tends to be more stable to use the .NET Core SDK to do so than
# to use the Debian package manager, due to issues with syncing libicu
# dependencies.
RUN dotnet tool install --global PowerShell --version 7.1.1

# Install Jupytext to expose Markdown files as Jupyter Notebooks for use with
# Binder.
RUN pip install jupytext
# Make the C# and PowerShell kernels available to Jupytext as well.
RUN dotnet tool install -g --add-source "https://pkgs.dev.azure.com/dnceng/public/_packaging/dotnet-tools/nuget/v3/index.json" Microsoft.dotnet-interactive && \
    dotnet interactive jupyter install

# On .NET 5 and later, we need to make sure that NuGet cache files are owned
# by the notebook user and not by root.
RUN chown -R ${USER}:${USER} /tmp/NuGetScratch

# Install additional Python dependencies for the PythonInterop sample.
# Note that QuTiP has as a hard requirement that its dependencies must be
# installed first, so we separate into two pip install steps.
RUN pip install cython \
                numpy \
                scipy && \
    pip install qutip
# We install the rest of our Python dependencies as a separate layer since
# building QuTiP can take a few moments. This makes it easier if we want to add
# other Python packages later.
RUN pip install "matplotlib<=2.1.2" \
                "ipyparallel" \
                "mpltools" \
                "qinfer"

# FIXME: The following is a workaround for https://github.com/microsoft/iqsharp/issues/404,
#        and should be removed when that issue is resolved.
RUN chown -R ${USER}:${USER} /home/${USER}/.azure

# NB: We don't drop back to USER here, deferring that to the binder-specific
#     Dockerfile in the root of the repo. This means that the devcontainer
#     runs as root in VS Code and GitHub Codespaces, as is the default for
#     both environments.
