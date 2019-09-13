# NAME:     homeland/homeland
FROM ruby:2.6.3-alpine

MAINTAINER Jason Lee "https://github.com/huacnlee"

# RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories
RUN apk --update add ca-certificates nodejs tzdata imagemagick &&\
    apk add --virtual .builddeps build-base ruby-dev libc-dev openssl linux-headers \
    libxml2-dev libxslt-dev postgresql-dev git curl

RUN curl https://get.acme.sh | sh

ENV RAILS_ROOT /var/www/homeland
ENV HOMELAND_VERSION "master"

RUN mkdir -p $RAILS_ROOT
WORKDIR $RAILS_ROOT

ADD Gemfile Gemfile.lock $RAILS_ROOT/
RUN gem install bundler
RUN bundle install --jobs 20 --retry 5
RUN bundle exec rails assets:precompile RAILS_ENV=production SECRET_KEY_BASE=bccfa7ece4826519009ebc132653b6db

ADD . $RAILS_ROOT

EXPOSE 3000
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
# CMD ["/bin/bash"]


