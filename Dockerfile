FROM sigost/openhub:base

COPY --chown=serv-deployer:serv-deployer . $APP_HOME
RUN chown -R serv-deployer:serv-deployer $APP_HOME

USER serv-deployer
RUN cd $APP_HOME \
  && gem install bundler:2.3.6 \
  && gem install nokogiri -v 1.11.7 \
  && gem install rails -v 5.2.6 \
  && bundle install \
  && RAILS_ENV=production ASSETS_PRECOMPILE=1 DATABASE_URL=nulldb://user:pass@127.0.0.1/dbname bundle exec rake assets:precompile

WORKDIR $APP_HOME
