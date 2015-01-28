class PositionDecorator < Draper::Decorator
  delegate_all

  # TODO: Replaces position_analyzed in account/reports.rb
  def analyzed?
    cbp = account.decorate.symbolized_commits_by_project.index_by { |c| c[:position_id].to_i }
    cbp[id].present?
  end
end
