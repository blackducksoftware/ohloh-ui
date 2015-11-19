class Clump < ActiveRecord::Base
  belongs_to :code_set
  belongs_to :slave
end
