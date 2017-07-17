class ProjectWidget::MonthlyStatisticsBadge < ProjectWidget
  def short_nice_name
    I18n.t('project_widgets.monthly_statistics_badge.short_nice_name')
  end

  def width
    245
  end

  def height
    50
  end

  def image
    image_data = [{ text: project.name.truncate(18).shellescape, align: :center }]
    image_data += monthly_statistics_text(project.best_analysis) if project.best_analysis
    WidgetBadge::Partner.create(image_data)
  end

  def position
    22
  end

  private

  def monthly_statistics_text(analysis)
    [{ text: I18n.t('project_widgets.monthly_statistics_badge.text'), align: :center },
     commits_text(analysis),
     contributors_text(analysis),
     new_contributors_text(analysis)]
  end

  def commits_text(analysis)
    commits_count = analysis.thirty_day_summary.commits_count
    commit = I18n.t('project_widgets.monthly_statistics_badge.commit').pluralize(commits_count)
    text = I18n.t('project_widgets.monthly_statistics_badge.commit_text',
                  text: commit, value: commits_count.to_human)
    { text: text, align: :center }
  end

  def contributors_text(analysis)
    contributors_count = analysis.thirty_day_summary.committer_count
    contributor = I18n.t('project_widgets.monthly_statistics_badge.contributor').pluralize(contributors_count)
    text = I18n.t('project_widgets.monthly_statistics_badge.contributor_text',
                  text: contributor, value: contributors_count.to_human)
    { text: text, align: :center }
  end

  def new_contributors_text(analysis)
    new_contributors_count = analysis.thirty_day_summary.new_contributors_count || 0
    new_contributor = I18n.t('project_widgets.monthly_statistics_badge.new_contributor')
                          .pluralize(new_contributors_count)
    text = I18n.t('project_widgets.monthly_statistics_badge.new_contributor_text',
                  text: new_contributor, value: new_contributors_count.to_human)
    { text: text, align: :center }
  end
end
