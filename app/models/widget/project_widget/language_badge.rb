class ProjectWidget::LanguageBadge < ProjectWidget
  def short_nice_name
    I18n.t('project_widgets.language_badge.short_nice_name')
  end

  def width
    245
  end

  def height
    50
  end

  def image
    image_data = [{ text: project.name.truncate(18).shellescape, align: :center }]
    image_data += languages_breakdown_text if project.best_analysis
    image_data += [{ text: 'Language Breakdown', align: :center }]
    WidgetBadge::Partner.create(image_data)
  end

  def position
    21
  end

  def language_name(languages_breakdown, lb)
    "#{ProjectWidgetsController.helpers.total_percent(languages_breakdown, lb)} #{lb.language_nice_name}"
  end

  private

  def languages_breakdown_text
    languages_breakdown = Analysis::LanguagesBreakdown.new(analysis: project.best_analysis).collection
    languages = I18n.t('project_widgets.language_badge.language').pluralize(languages_breakdown.count)
    total_count_text = I18n.t('project_widgets.language_badge.total_count',
                              text: languages, count: languages_breakdown.count.to_human)
    languages_text = [{ text: total_count_text, align: :center }]

    language_names(languages_breakdown).each do |language_text|
      languages_text << { text: language_text, align: :center }
    end
    languages_text
  end

  def language_names(languages_breakdown)
    languages_breakdown.map { |lb| [language_name(languages_breakdown, lb)] }.flatten
  end
end
