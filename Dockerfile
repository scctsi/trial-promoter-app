FROM ruby:2.3.3

# Create a directory for your application code and set it as the WORKDIR. All following commands will be run in this directory.
RUN mkdir /app
WORKDIR /app

# COPY Gemfile and Gemfile.lock and install dependencies before adding the full code so the cache only
# gets invalidated when dependencies are changed
COPY Gemfile ./Gemfile
COPY Gemfile.lock ./Gemfile.lock 
RUN gem install bundler
RUN bundle

# Copy the app source code into the image
COPY . .
