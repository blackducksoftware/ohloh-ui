# frozen_string_literal: true

module SqlTracker
  class Handler
    def tracked_sql_matcher
      @tracked_sql_matcher ||= /#{@config.tracked_sql_command.join('|')}/
    end
  end
end
