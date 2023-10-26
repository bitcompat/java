# syntax=docker/dockerfile:1.4

ARG JAVA_VERSION="21.0.1"
ARG PACKAGE_VERSION="${JAVA_VERSION}+12"

FROM docker.io/bitnami/minideb:bookworm as builder

ARG JAVA_VERSION
ARG PACKAGE_VERSION

LABEL org.opencontainers.image.ref.name="${JAVA_VERSION}-debian-12-r1" \
      org.opencontainers.image.title="java" \
      org.opencontainers.image.version="${JAVA_VERSION}"

COPY prebuildfs /
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

COPY --link --from=ghcr.io/bitcompat/gosu:1.16.0 /opt/bitnami/ /opt/bitnami/
RUN install_packages acl ca-certificates curl gzip libc6 libsqlite3-dev libssl-dev locales procps tar wget zlib1g curl unzip zip

RUN <<EOT bash
    set -eux
    export JAVA_MAJOR=\$(echo "${JAVA_VERSION}" | cut -d'.' -f1)
    export JAVA_FULL_VERSION=\$(echo "${PACKAGE_VERSION}" | cut -d'+' -f1)
    export JAVA_REVISION=\$(echo "\${JAVA_FULL_VERSION}" | cut -d'.' -f4)

    ARCH=$(uname -m)
    if [ "\$ARCH" == "x86_64" ]; then
      ARCH="amd64"
    fi

    mkdir -p /opt/src
    cd /opt/src
    curl -fsSL -o jdk-${JAVA_VERSION}.tar.gz "https://download.bell-sw.com/java/${PACKAGE_VERSION}/bellsoft-jdk${PACKAGE_VERSION}-linux-\$ARCH.tar.gz"
    tar xf jdk-${JAVA_VERSION}.tar.gz

    mkdir -p /opt/bitnami/java
    mv /opt/src/jdk-\${JAVA_FULL_VERSION}/* /opt/bitnami/java/

    cd /opt/bitnami/java
    mkdir licenses
    mv LICENSE licenses/java-${JAVA_VERSION}-\${JAVA_REVISION}.txt
    echo "java-${JAVA_VERSION}-\${JAVA_REVISION},GPL2,https://download.bell-sw.com/java/${PACKAGE_VERSION}/bellsoft-jdk${PACKAGE_VERSION}-linux-src-full.tar.gz" > licenses/gpl-source-links.txt
EOT

COPY --link rootfs /

FROM docker.io/bitnami/minideb:bookworm as stage-0

COPY --link --from=builder /opt/bitnami /opt/bitnami
ARG JAVA_EXTRA_SECURITY_DIR="/bitnami/java/extra-security"

RUN <<EOT bash
    set -eux
    install_packages ca-certificates gzip libc6 libsqlite3-dev libssl-dev locales procps tar wget zlib1g

    localedef -c -f UTF-8 -i en_US en_US.UTF-8
    update-locale LANG=C.UTF-8 LC_MESSAGES=POSIX
    DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales
    echo 'en_GB.UTF-8 UTF-8' >> /etc/locale.gen && locale-gen
    echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen && locale-gen
    sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS    90/' /etc/login.defs && \
        sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS    0/' /etc/login.defs && \
        sed -i 's/sha512/sha512 minlen=8/' /etc/pam.d/common-password

    /opt/bitnami/scripts/locales/add-extra-locales.sh
    /opt/bitnami/scripts/java/postunpack.sh
EOT

ARG TARGETARCH
ENV HOME="/" \
    OS_ARCH="${TARGETARCH}" \
    OS_FLAVOUR="debian-11" \
    OS_NAME="linux" \
    APP_VERSION="${JAVA_VERSION}-1" \
    BITNAMI_APP_NAME="java" \
    JAVA_HOME="/opt/bitnami/java" \
    LANG="en_US.UTF-8" \
    LANGUAGE="en_US:en" \
    PATH="/opt/bitnami/java/bin:/opt/bitnami/common/bin:$PATH"

ENTRYPOINT [ "/opt/bitnami/scripts/java/entrypoint.sh" ]
CMD [ "bash" ]
