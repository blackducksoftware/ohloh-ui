# frozen_string_literal: true

class AddIndexToPeopleNameIdKudoPosition < ActiveRecord::Migration[6.1]
  def change
    add_index :people, %i[name_id kudo_position],
              where: 'name_id IS NOT NULL',
              name: 'index_people_name_id_kudo_position'
  end
end
