# frozen_string_literal: true

class RenameVerificationsAuthColumns < ActiveRecord::Migration
  def change
    rename_column :verifications, :auth_id, :token
    add_column :verifications, :unique_id, :string

    Verification.connection.execute('update verifications set unique_id = token')
  end
end
