# frozen_string_literal: true

task update_code_set_fetched_at: :environment do
  ActiveRecord::Base.connection.execute("
    UPDATE code_sets
      SET fetched_at = (
        SELECT MAX(fetched_at)
          FROM clumps
          WHERE code_sets.id = clumps.code_set_id
      )
  ")
end
