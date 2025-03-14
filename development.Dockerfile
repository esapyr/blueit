# syntax=docker/dockerfile:1
# check=error=true

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
ARG RUBY_VERSION=3.4.2
FROM docker.io/library/ruby:$RUBY_VERSION AS base

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y jq

# Install websocat
RUN curl --output /usr/local/bin/websocat -L "https://github.com/vi/websocat/releases/download/v1.14.0/websocat_max.aarch64-unknown-linux-musl" && \
    chmod a+x /usr/local/bin/websocat

WORKDIR /app
COPY . .
RUN bundle install
