class ImportForeignTableRegistrationKeys < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        execute <<-SQL
          IMPORT FOREIGN SCHEMA public LIMIT TO (registration_keys) FROM SERVER fis INTO PUBLIC options(import_default 'true')
        SQL
      end

      dir.down do
        execute <<-SQL
          DROP FOREIGN TABLE registration_keys
        SQL
      end
    end
  end
end
