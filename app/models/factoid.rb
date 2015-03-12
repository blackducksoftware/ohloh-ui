class Factoid < ActiveRecord::Base
  belongs_to :analysis
  belongs_to :language
  belongs_to :license
end
