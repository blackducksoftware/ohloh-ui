class Name < ActiveRecord::Base
  has_many :name_facts
  has_many :people

  fix_string_column_encodings!

  class << self
    def from_param(id_or_name)
      where('id = ? or name = ?', id_or_name.to_i, id_or_name)
    end
  end
end
