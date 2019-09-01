# NAME:     homeland/homeland
FROM ruby:2.6.3-alpine

MAINTAINER Jason Lee "https://github.com/huacnlee"
RUN gem install bundler
# RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories
RUN apk --update add ca-certificates nodejs tzdata imagemagick &&\
    apk add --virtual .builddeps build-base ruby-dev libc-dev openssl linux-headers \
    libxml2-dev libxslt-dev postgresql-dev git curl

RUN curl https://get.acme.sh | sh

ENV RAILS_ENV "production"
ENV HOMELAND_VERSION "master"

WORKDIR /var/www/homeland

RUN mkdir -p /var/www &&\
		find / -type f -iname '*.apk-new' -delete &&\
		rm -rf '/var/cache/apk/*' '/tmp/*' '/var/lib/apt/lists/*'

ADD Gemfile Gemfile.lock /var/www/homeland/
RUN bundle install --deployment --jobs 20 --retry 5 &&\
		find /var/www/homeland/vendor/bundle -name tmp -type d -exec rm -rf {} +
ADD . /var/www/homeland

RUN rm -Rf /var/www/homeland/vendor/cache

RUN bundle exec rails assets:precompile RAILS_ENV=production SECRET_KEY_BASE=bccfa7ece4826519009ebc132653b6db

EXPOSE 3000
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
# CMD ["/bin/bash"]


