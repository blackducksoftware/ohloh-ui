class AnalysisAlias < ActiveRecord::Base
  belongs_to :analysis
  belongs_to :commit_name, class_name: 'Name', foreign_key: :commit_name_id
  belongs_to :preferred_name, class_name: 'Name', foreign_key: :preferred_name_id
end
