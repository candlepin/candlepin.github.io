FROM ruby:2.7-slim-bullseye

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

ENTRYPOINT [ "jekyll" ]

CMD [ "--help" ]
