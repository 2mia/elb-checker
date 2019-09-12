FROM ruby:2.5.3


RUN apt-get update
RUN apt-get install dnsutils whois -y

WORKDIR /app
ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock
RUN bundle install --system

ADD . /app
RUN bundle install --system

EXPOSE 9292

CMD ["puma"]
