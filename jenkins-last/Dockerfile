FROM jenkins/jenkins:2.346.2

# switch to root, let the entrypoint drop back to jenkins
USER root

# install prerequisite debian packages
RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
     apt-transport-https \
     ca-certificates \
     curl \
     gnupg2 \
     software-properties-common \
     vim \
     wget \
     procps \
     psmisc \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# install gosu for a better su+exec command
ARG GOSU_VERSION=1.12
RUN dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
 && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch" \
 && chmod +x /usr/local/bin/gosu \
 && gosu nobody true

COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --verbose --plugin-file /usr/share/jenkins/ref/plugins.txt

COPY init.groovy.d/ /usr/share/jenkins/ref/init.groovy.d/
COPY jenkins-home /var/jenkins_home
COPY entrypoint.sh /entrypoint.sh
RUN chown -R jenkins:jenkins /var/jenkins_home \
 && chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
HEALTHCHECK CMD curl -sSLf http://localhost:8080/login >/dev/null || exit 1
