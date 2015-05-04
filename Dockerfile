FROM phusion/passenger-ruby22:0.9.15
MAINTAINER OpenHub <info@ohloh.net>

RUN rm /etc/nginx/sites-enabled/default
ADD config/nginx.conf /etc/nginx/sites-enabled/webapp.conf
RUN rm -f /etc/service/nginx/down

RUN mkdir /home/app/webapp
WORKDIR /home/app/webapp

ADD Gemfile /home/app/webapp/Gemfile
ADD Gemfile.lock /home/app/webapp/Gemfile.lock
RUN bundle install --deployment

ADD . /home/app/webapp

RUN rake assets:precompile RAILS_ENV=production

CMD ["/sbin/my_init"]
EXPOSE 80

RUN apt-get -y clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
