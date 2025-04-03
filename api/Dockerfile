FROM ruby:3.2.2

# Install essential packages
RUN apt-get update -qq && \
    apt-get install -y build-essential default-libmysqlclient-dev nodejs && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Install Rails and Bundler
RUN gem install bundler && \
    gem install rails -v 7.1.0

# Copy entrypoint script
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]
CMD ["rails", "server", "-b", "0.0.0.0"]