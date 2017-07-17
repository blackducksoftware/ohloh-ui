class ProjectWidget::YearlyStatisticsBadge < ProjectWidget
  def short_nice_name
    I18n.t('project_widgets.yearly_statistics_badge.short_nice_name')
  end

  def width
    245
  end

  def height
    50
  end

  def image
    image_data = [{ text: project.name.truncate(18).shellescape, align: :center }]
    image_data += yearly_statistics_text(project.best_analysis) if project.best_analysis
    WidgetBadge::Partner.create(image_data)
  end

  def position
    23
  end

  private

  def yearly_statistics_text(analysis)
    [{ text: I18n.t('project_widgets.yearly_statistics_badge.text'), align: :center },
     commits_text(analysis), old_commits_text(analysis),
     contributors_text(analysis), old_contributors_text(analysis)]
  end

  def commits_text(analysis)
    commits_count = analysis.twelve_month_summary.commits_count
    commit = I18n.t('project_widgets.yearly_statistics_badge.commit').pluralize(commits_count)
    commits_text = I18n.t('project_widgets.yearly_statistics_badge.commit_text',
                          text: commit, value: commits_count.to_human)
    { text: commits_text, align: :center }
  end

  def old_commits_text(analysis)
    commits_diff = analysis.previous_twelve_month_summary.commits_difference
    { text: commitment_trend(commits_diff), align: :center }
  end

  def contributors_text(analysis)
    contributors_count = analysis.twelve_month_summary.committer_count
    contributor = I18n.t('project_widgets.yearly_statistics_badge.contributor').pluralize(contributors_count)
    contributors_text = I18n.t('project_widgets.yearly_statistics_badge.contributor_text',
                               text: contributor, value: contributors_count.to_human)
    { text: contributors_text, align: :center }
  end

  def old_contributors_text(analysis)
    committers_diff = analysis.previous_twelve_month_summary.committers_difference
    { text: commitment_trend(committers_diff), align: :center }
  end

  def commitment_trend(count)
    if count > 0
      I18n.t('project_widgets.yearly_statistics_badge.positive_diff', value: count.to_human)
    else
      I18n.t('project_widgets.yearly_statistics_badge.negative_diff', value: "-#{count.abs.to_human}")
    end
  end
end
