class ProjectWidget::LastUpdateBadge < ProjectWidget
  def short_nice_name
    I18n.t('project_widgets.last_update_badge.short_nice_name')
  end

  def width
    245
  end

  def height
    50
  end

  def image
    image_data = [{ text: project.name.truncate(18).shellescape, align: :center }]
    image_data += analysed_text(project.best_analysis) if project.best_analysis
    WidgetBadge::Partner.create(image_data)
  end

  def position
    18
  end

  private

  def analysed_text(analysis)
    [{ text: I18n.t('project_widgets.last_update_badge.last_analysed'), align: :center },
     { text: time_ago_in_words(analysis.updated_on), align: :center },
     code_fetch_text(analysis)].flatten.compact
  end

  def code_fetch_text(analysis)
    [{ text: I18n.t('project_widgets.last_update_badge.last_fetched'), align: :center },
     { text: time_ago_in_words(analysis.oldest_code_set_time), align: :center }] if analysis.oldest_code_set_time
  end

  def time_ago_in_words(time)
    "#{ApplicationController.helpers.time_ago_in_words(time).humanize} #{I18n.t('.ago')}"
  end
end
