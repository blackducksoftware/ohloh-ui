require "#{Rails.root}/lib/oh_delegator/parent_scope"
require "#{Rails.root}/lib/oh_delegator/base"
require "#{Rails.root}/lib/oh_delegator/delegable"
require "#{Rails.root}/lib/oh_delegator/orm"

ActiveSupport.on_load(:active_record) do
  OhDelegator::ORM.setup(self)
end
