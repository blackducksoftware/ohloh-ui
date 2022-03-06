# frozen_string_literal: true

class RemoveMeaninglessForeignKeyConstraintOnAttachments < ActiveRecord::Migration[4.2]
  def change
    remove_foreign_key :attachments, name: :attachments_parent_id_fkey
  end
end
