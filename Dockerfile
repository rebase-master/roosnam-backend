# syntax=docker/dockerfile:1
# check=error=true

# This Dockerfile works for both development and production.
# Use docker-compose.yml to override environment variables for development.

ARG RUBY_VERSION=3.2.4
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

WORKDIR /rails

# Install base packages (including nodejs and yarn for asset compilation)
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libjemalloc2 libvips sqlite3 nodejs yarn && \
    ln -s /usr/lib/$(uname -m)-linux-gnu/libjemalloc.so.2 /usr/local/lib/libjemalloc.so && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Default to production settings (override these in docker-compose.yml for development)
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    LD_PRELOAD="/usr/local/lib/libjemalloc.so"
# Note: BUNDLE_WITHOUT is not set here - it will be set by docker-compose.yml
# For production, set BUNDLE_WITHOUT="development:test" in your deployment config

FROM base

# Install build dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libyaml-dev pkg-config && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Create directories and non-root user
RUN mkdir -p /rails/tmp /rails/log /rails/storage && \
    groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash

# Copy dependency files for gem installation
COPY --chown=rails:rails Gemfile Gemfile.lock ./

# Copy vendor directory if you have vendored gems
COPY --chown=rails:rails vendor ./vendor

# Install ALL gems (including dev/test) to support both environments
# The BUNDLE_WITHOUT env var will be overridden by docker-compose for development
RUN BUNDLE_WITHOUT="" bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Copy application code
COPY --chown=rails:rails . .

# Precompile bootsnap cache for application code
RUN bundle exec bootsnap precompile app/ lib/

# Copy and make entrypoint executable
COPY --chown=rails:rails entrypoint.sh /rails/entrypoint.sh
RUN chmod +x /rails/entrypoint.sh

# Ensure proper ownership of all directories including bundle path
# Create cache directory structure and ensure it's writable
RUN chown -R rails:rails /rails/tmp /rails/log /rails/storage "${BUNDLE_PATH}" && \
    mkdir -p "${BUNDLE_PATH}"/ruby/3.2.0/cache && \
    chown -R rails:rails "${BUNDLE_PATH}"

# Switch to non-root user
USER 1000:1000

# Use custom entrypoint for database setup
ENTRYPOINT ["/rails/entrypoint.sh"]

# Default command
EXPOSE 3000
CMD ["./bin/rails", "server", "-b", "0.0.0.0", "-p", "3000"]
