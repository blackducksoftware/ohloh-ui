class Invite < ActiveRecord::Base
  belongs_to :project
  belongs_to :invitor, class_name: 'Account'
  belongs_to :invitee, class_name: 'Account'
end
