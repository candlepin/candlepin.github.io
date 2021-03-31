FROM centos/ruby-27-centos7

LABEL name="candlepin/website-ruby-27" \
      maintainer="Alex Wood <awood@redhat.com>"

USER root

RUN yum install -y --setopt=tsflags=nodocs java-1.8.0-openjdk-devel graphviz && \
    yum clean all -y

COPY ./.s2i/lib/plantuml.jar /usr/share/java/plantuml.jar
COPY ./.s2i/lib/plantuml /usr/bin/plantuml
RUN chmod 755 /usr/bin/plantuml

COPY ./.s2i/bin/ $STI_SCRIPTS_PATH

USER 1001

