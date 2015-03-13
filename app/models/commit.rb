class Commit < ActiveRecord::Base
  belongs_to :code_set
  belongs_to :name
end
