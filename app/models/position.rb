class Position < ActiveRecord::Base
	belongs_to :project
	belongs_to :affiliation, class_name: 'Organization', foreign_key: :organization_id
end
