class PositionDecorator < Draper::Decorator
  delegate_all

  def analyzed?
    cbp = account.decorate.symbolized_commits_by_project.index_by { |cbp| cbp[:position_id].to_i }
    cbp[id].present?
  end
end
