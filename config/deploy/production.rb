# frozen_string_literal: true

set :web_heads, ['serv-deployer@sdc-oh-web04.prd.sig.synopsys.com',
                 'serv-deployer@sdc-oh-web05.prd.sig.synopsys.com',
                 'serv-deployer@sdc-oh-web06.prd.sig.synopsys.com']

set :utility, 'sdc-oh-utility01.prd.sig.synopsys.com'

namespace :deploy do
  task started: 'docker:deploy'
  task offline: 'docker:offline'
  task online:  'docker:online'
  task utility: 'docker:utility'
end
