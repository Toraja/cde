ARG BASE_IMAGE_NAME
ARG BASE_IMAGE_TAG
FROM ${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}

USER root

ARG VERSION
RUN apt-get update && apt-get install --no-install-recommends --yes \
    openjdk-${VERSION}-jdk \
    && rm -rf /var/lib/apt/lists/*

ARG USER
USER ${USER}

# Maybe it's better to do this manually in a bind mounted directory after image
# is built because it takes very long time to complete.
# Though the document on github does not specify, build fails with `-DskipTests` option.
RUN git clone https://github.com/eclipse/eclipse.jdt.ls.git \
    && cd eclipse.jdt.ls \
    && ./mvnw clean verify -DskipTests

CMD ["tail", "-f", "/dev/null"]
