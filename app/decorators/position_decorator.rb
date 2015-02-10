class PositionDecorator < Cherry::Decorator
  # TODO: Replaces position_analyzed in account/reports.rb
  def analyzed?
    cbp = position.account.decorate.symbolized_commits_by_project.index_by { |c| c[:position_id].to_i }
    cbp[position.id].present?
  end
end
