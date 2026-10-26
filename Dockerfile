FROM docker.io/library/ruby:3.3-slim-bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    graphviz \
    plantuml \
    python3 \
    && rm -rf /var/lib/apt/lists/*

COPY Gemfile* .
RUN bundle install && \
    rm -rf Gemfile*

EXPOSE 4000

WORKDIR /site

ENTRYPOINT [ "bundle", "exec", "jekyll" ]

CMD [ "--help" ]
