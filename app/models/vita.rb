class Vita < ActiveRecord::Base
  self.table_name = 'vitae'
  belongs_to :account
  has_one :vita_fact
  has_many :vita_language_facts

  def vita_fact
    VitaFact.where(vita_id: id).first || NilVitaFact.new
  end
end
