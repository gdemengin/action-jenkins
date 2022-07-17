FROM jenkins/jenkins:lts

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
     libxml-xpath-perl \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --verbose --plugin-file /usr/share/jenkins/ref/plugins.txt

COPY init.groovy.d/ /usr/share/jenkins/ref/init.groovy.d/
COPY jenkins_home /var/jenkins_home
COPY entrypoint.sh /entrypoint.sh
COPY env /env
RUN chown -R jenkins:jenkins /var/jenkins_home \
 && chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
HEALTHCHECK CMD curl -sSLf http://localhost:8080/login >/dev/null || exit 1
