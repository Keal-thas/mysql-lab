# `mysqlbinlog` + `mysql` client, for decoding/replaying the lab's binlog.
#
# Why this exists: the official `mysql:8.4` image (this project's `mysql`
# service) is arm64 on Apple Silicon, and on arm64 Oracle only publishes the
# "server-minimal" RPM -- it doesn't include client tools like `mysqlbinlog`
# at all (confirmed: neither the yum repo baked into that image, nor MySQL's
# own Debian apt repo, ship arm64 builds of the client packages). The real
# `mysqlbinlog` binary only exists as an amd64 build, bundled inside the
# `mysql-community-server-core` .deb (not a client package) -- so this image
# runs it under x86_64 emulation, which Docker Desktop's Apple Silicon
# VM supports out of the box.
FROM --platform=linux/amd64 debian:12-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
      gnupg lsb-release wget ca-certificates \
    && gpg --keyserver keyserver.ubuntu.com --recv-keys B7B3B788A8D3785C \
    && gpg --export B7B3B788A8D3785C > /usr/share/keyrings/mysql.gpg \
    && wget -q https://dev.mysql.com/get/mysql-apt-config_0.8.33-1_all.deb -O /tmp/mysql-apt-config.deb \
    && DEBIAN_FRONTEND=noninteractive dpkg -i /tmp/mysql-apt-config.deb \
    && sed -i 's|signed-by=[^]]*|signed-by=/usr/share/keyrings/mysql.gpg|' /etc/apt/sources.list.d/mysql.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends mysql-community-client-core \
    && apt-get download mysql-community-server-core \
    && dpkg-deb -x mysql-community-server-core*.deb /tmp/extracted \
    && cp /tmp/extracted/usr/bin/mysqlbinlog /usr/bin/mysqlbinlog \
    && apt-get purge -y gnupg wget lsb-release && apt-get autoremove -y \
    && rm -rf /tmp/* /var/lib/apt/lists/* ./*.deb \
    && mysqlbinlog --version

ENTRYPOINT ["/bin/bash", "-c", "exec \"$@\"", "--"]
