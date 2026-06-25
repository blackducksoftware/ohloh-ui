# frozen_string_literal: true

class AddIndexToPeopleNameIdKudoPosition < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index :people, %i[name_id kudo_position],
              where: 'name_id IS NOT NULL',
              name: 'index_people_name_id_kudo_position',
              algorithm: :concurrently
  end
end
