# frozen_string_literal: true

class CommitFlag::BackToLife < CommitFlag
  def time_elapsed
    data[:time_elapsed] if data
  end

  def time_elapsed=(interval)
    self.data ||= {}
    self.data[:time_elapsed] = interval
  end
end
