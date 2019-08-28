# frozen_string_literal: true

class ActiveRecord::Migrator
  class << self
    def any_migrations?
      true
    end
  end
end
