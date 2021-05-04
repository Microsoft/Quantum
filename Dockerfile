# This uses the latest Docker image built from the samples repository,
# defined by the Dockerfile in Build/images/samples.
FROM mcr.microsoft.com/quantum/samples:f4b26d9a9914d2f3fa0fe177549da32728927b71

# Mark that this Dockerfile is used with the samples repository.
ENV IQSHARP_HOSTING_ENV=SAMPLES_HOSTED

# Make sure the contents of our repo are in ${HOME}.
# These steps are required for use on mybinder.org.
USER root
COPY . ${HOME}
RUN chown -R ${USER} ${HOME}

# Finish by dropping back to the notebook user.
USER ${USER}
