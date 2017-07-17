class ProjectWidget::RecentContributorsBadge < ProjectWidget
  def short_nice_name
    I18n.t('project_widgets.recent_contributors_badge.short_nice_name')
  end

  def width
    245
  end

  def height
    50
  end

  def image
    image_data = [{ text: project.name.truncate(18).shellescape, align: :center }]
    image_data += contributors_text(project.best_analysis) if project.best_analysis
    WidgetBadge::Partner.create(image_data)
  end

  def position
    20
  end

  private

  def contributors_text(analysis)
    contributors = [{ text: I18n.t('project_widgets.recent_contributors_badge.text'), align: :center }]
    analysis.all_time_summary.recent_contribution_persons.take(5).map(&:effective_name).each do |name|
      contributors << { text: name, align: :center }
    end
    contributors
  end
end
