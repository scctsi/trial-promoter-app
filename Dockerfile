FROM ruby:2.3.3
RUN apt-get update && apt-get install -qq -y build-essential nodejs libpq-dev postgresql-client-9.4 --fix-missing --no-install-recommends

# Create a directory for your application code and set it as the WORKDIR. All following commands will be run in this directory.
ENV INSTALL_PATH /trial-promoter-app
RUN mkdir -p $INSTALL_PATH
WORKDIR $INSTALL_PATH

# COPY Gemfile and Gemfile.lock and install dependencies before adding the full code so the cache only
# gets invalidated when dependencies are changed
COPY Gemfile Gemfile

RUN gem install bundler
RUN bundle install

# Copy the app source code into the image
COPY . .
CMD rails s
