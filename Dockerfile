# syntax=docker/dockerfile:1
# check=error=true

# This Dockerfile is flexible for both production and development, 
# with configuration managed via docker-compose.yml.

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
ARG RUBY_VERSION=3.2.4
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

# Rails app lives here
WORKDIR /rails

# Install base packages
# Includes nodejs and yarn for asset compilation flexibility (required for development).
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libjemalloc2 libvips sqlite3 nodejs yarn && \
    ln -s /usr/lib/$(uname -m)-linux-gnu/libjemalloc.so.2 /usr/local/lib/libjemalloc.so && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Set default production environment variables (OVERRIDDEN for development in docker-compose)
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development" \
    LD_PRELOAD="/usr/local/lib/libjemalloc.so"

# --- FINAL STAGE (Production Ready Image) ---
FROM base

# Install packages needed to build and install gems in the Docker image
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libyaml-dev pkg-config && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# ----------------------------------------------------------------------
# 1. SETUP USER AND DIRECTORIES (AS ROOT)
# ----------------------------------------------------------------------

# Create the necessary writable directories 
RUN mkdir -p /rails/tmp /rails/log /rails/storage
# Create the non-root user that will run the application
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash

# ----------------------------------------------------------------------
# 2. INSTALL GEMS IN DOCKER IMAGE (Not from local bundle)
# ----------------------------------------------------------------------

# Copy Gemfile and Gemfile.lock first for dependency installation
# This allows Docker to cache the gem installation layer
COPY --chown=rails:rails Gemfile Gemfile.lock ./

# Install vendor directory if it exists (for vendored gems)
COPY --chown=rails:rails vendor ./vendor

# Install all gems fresh in the Docker image (independent of local machine)
# Install ALL gems including development/test for flexibility (docker-compose can restrict later)
# Override BUNDLE_WITHOUT to install everything during build
RUN BUNDLE_WITHOUT="" bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

# ----------------------------------------------------------------------
# 3. COPY APPLICATION CODE
# ----------------------------------------------------------------------

# Copy application code (after gems are installed for better Docker layer caching)
COPY --chown=rails:rails . .

# Copy and make entrypoint executable
COPY --chown=rails:rails entrypoint.sh /rails/entrypoint.sh
RUN chmod +x /rails/entrypoint.sh

# Ensure the necessary directories are owned by the 'rails' user.
RUN chown -R rails:rails /rails/tmp /rails/log /rails/storage

# ----------------------------------------------------------------------
# 2. SWITCH TO NON-ROOT USER
# ----------------------------------------------------------------------
USER 1000:1000

# ----------------------------------------------------------------------
# 3. ENTRYPOINT/CMD
# ----------------------------------------------------------------------
# Entrypoint prepares the database (e.g., checks connection, migrates)
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Start server via Thruster by default (suitable for production)
EXPOSE 80
CMD ["./bin/thrust", "./bin/rails", "server"]
 