FROM centos/ruby-27-centos7

LABEL name="candlepin/website-ruby-27" \
      maintainer="Alex Wood <awood@redhat.com>"

USER root

RUN yum install -y --setopt=tsflags=nodocs java-1.8.0-openjdk-devel graphviz python3 && \
    yum clean all -y

# Keep this value up to date with the BUNDLED WITH version in Gemfile.lock
RUN gem install bundler:2.3.10

COPY ./.s2i/lib/plantuml.jar /usr/share/java/plantuml.jar
COPY ./.s2i/lib/plantuml /usr/bin/plantuml
RUN chmod 755 /usr/bin/plantuml

COPY ./.s2i/bin/ $STI_SCRIPTS_PATH

# Drop the root user and make the content of /opt/app-root owned by user 1001
RUN chown -R 1001:0 ${APP_ROOT} && chmod -R ug+rwx ${APP_ROOT} && \
    rpm-file-permissions

USER 1001

