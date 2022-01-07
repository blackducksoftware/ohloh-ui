FROM sigost/openhub:base

COPY --chown=serv-deployer:serv-deployer . $APP_HOME
RUN chown -R serv-deployer:serv-deployer $APP_HOME

USER serv-deployer
RUN cd $APP_HOME \
  && gem install bundler:1.17.3 \
  && gem install rails -v 4.2.11.1 \
  && bundle install \
  && RAILS_ENV=production DATABASE_URL=nulldb://user:pass@127.0.0.1/dbname bundle exec rake assets:precompile

WORKDIR $APP_HOME
