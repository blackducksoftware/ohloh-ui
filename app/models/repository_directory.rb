class RepositoryDirectory < ActiveRecord::Base
  belongs_to :repository
  belongs_to :code_location
end
