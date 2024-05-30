ARG STACK_VERSION
FROM --platform=linux/amd64 heroku/heroku:${STACK_VERSION}-build as build

# This ARG duplication is required since the lines before and after the 'FROM' are in different scopes.
ARG STACK_VERSION
ENV STACK="heroku-${STACK_VERSION}"

# On Heroku-24 and later the default user is not root.
# Once support for Heroku-22 and older is removed, the `useradd` steps below can be removed.
USER root

# Emulate the platform where root access is not available
RUN useradd -m non-root-user
USER non-root-user
RUN mkdir -p /tmp/build /tmp/cache /tmp/env
COPY --chown=non-root-user . /buildpack

# Sanitize the environment seen by the buildpack, to prevent reliance on
# environment variables that won't be present when it's run by Heroku CI.
RUN env -i PATH=$PATH HOME=$HOME STACK=$STACK /buildpack/bin/detect /tmp/build
RUN env -i PATH=$PATH HOME=$HOME STACK=$STACK /buildpack/bin/compile /tmp/build /tmp/cache /tmp/env

# We must then test against the run image since that has fewer system libraries installed.
FROM --platform=linux/amd64 heroku/heroku:${STACK_VERSION}
USER root
# Emulate the platform where root access is not available
RUN useradd -m non-root-user
USER non-root-user
COPY --from=build --chown=non-root-user /tmp/build /app
# Emulate the platform which sources all .profile.d/ scripts on app boot.
RUN echo 'for f in /app/.profile.d/*; do source "${f}"; done' > /app/.profile
ENV HOME=/app
WORKDIR /app
# We have to use a login bash shell otherwise the .profile script won't be run.
CMD ["bash", "-l"]
