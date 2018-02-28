class DropForeignKeyOnEnlistments < ActiveRecord::Migration
  def change
    if foreign_keys(:enlistments).any?{|k| k[:to_table] == 'repositories'}
      remove_foreign_key :enlistments, :repositories
    end
  end
end
