#!/bin/bash

podman build -t candlepin/jekyll -f Dockerfile

podman run --rm -p 4000:4000 -v "$(pwd)":/site:Z candlepin/jekyll serve --livereload --force_polling -H "0.0.0.0" -P 4000
