class Vita < ActiveRecord::Base
  self.table_name = 'vitae'
  belongs_to :account
  has_one :vita_fact
end
