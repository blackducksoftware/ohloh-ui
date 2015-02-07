class Vita < ActiveRecord::Base
  self.table_name = 'vitae'
  belongs_to :account
  has_one :vita_fact

  def vita_fact
    VitaFact.where(vita_id: id).first || NilVitaFact.new
  end
end
