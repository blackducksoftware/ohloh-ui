# frozen_string_literal: true

set :web_heads, ['serv-deployer@prd-oh-web04.dc2.lan', 'serv-deployer@prd-oh-web05.dc2.lan',
                 'serv-deployer@prd-oh-web06.dc2.lan']

set :utility, 'serv-deployer@prd-oh-utility01.dc2.lan'

namespace :deploy do
  task started: 'docker:deploy'
  task offline: 'docker:offline'
  task online:  'docker:online'
  task utility: 'docker:utility'
end
