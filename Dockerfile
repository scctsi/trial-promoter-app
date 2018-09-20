ROM ruby:2.3.3
RUN apt-get update && apt-get install -qq -y build-essential nodejs libpq-dev postgresql-client-9.4 --fix-missing --no-install-recommends

RUN mkdir /app
WORKDIR /app
COPY Gemfile /app/Gemfile
RUN bundle install
# Copy the app source code into the image
COPY . .
