# frozen_string_literal: true

module PositionsHelper
  def show_position_url(position)
    if position.project_id && position.contribution
      project_contributor_url(position.project, position.contribution.id)
    else
      account_position_url(position.account, position)
    end
  end
end
