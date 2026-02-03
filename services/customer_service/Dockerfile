FROM ruby:3.3

RUN apt-get update -y && apt-get install -y build-essential libpq-dev nodejs && rm -rf /var/lib/apt/lists/*
WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .
EXPOSE 3002
CMD ["bash", "-lc", "bundle exec rails s -b 0.0.0.0 -p ${PORT:-3002}"]
