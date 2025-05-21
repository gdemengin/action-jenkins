FROM jenkins/jenkins:lts

USER root

# patch sources.list for old debian versions
# https://stackoverflow.com/questions/76094428/debian-stretch-repositories-404-not-found
RUN \
    if [ $(cat /etc/apt/sources.list | grep stretch-updates | wc -l) != 0 ]; then \
        sed -i s/deb.debian.org/archive.debian.org/g /etc/apt/sources.list; \
        sed -i 's|security.debian.org|archive.debian.org/debian-security/|g' /etc/apt/sources.list; \
        sed -i '/stretch\/updates/d' /etc/apt/sources.list; \
        sed -i '/stretch-updates/d' /etc/apt/sources.list; \
    fi

# install prerequisite debian packages
RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends --allow-unauthenticated \
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

# remove expired certificates (required to get plugins on old versions)
RUN \
    if [ $(grep X3 /etc/ca-certificates.conf | wc -l) != 0 ]; then \
        sed -i '/^mozilla\/DST_Root_CA_X3/s/^/!/' /etc/ca-certificates.conf; \
        update-ca-certificates -f; \
    fi

COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
# use jenkins-plugin-cli when present, otherwise fallback to old install-plugins.sh
# but it does not manage versions of dependencies correctly so specify explicitely versions to use
# https://issues.jenkins.io/browse/JENKINS-40905
RUN \
    if [ $(cat /usr/share/jenkins/ref/plugins.txt | wc -l) != 0 ]; then \
        if which jenkins-plugin-cli; then \
            jenkins-plugin-cli --verbose --plugin-file /usr/share/jenkins/ref/plugins.txt; \
        else \
            /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt; \
        fi; \
    fi

COPY init.groovy.d/ /usr/share/jenkins/ref/init.groovy.d/
COPY jenkins_home/ /var/jenkins_home
COPY entrypoint/ /entrypoint
RUN chown -R jenkins:jenkins /var/jenkins_home \
 && chmod +x /entrypoint/entrypoint.sh

ENTRYPOINT ["/entrypoint/entrypoint.sh"]
HEALTHCHECK CMD curl -sSLf http://localhost:8080/login >/dev/null || exit 1
