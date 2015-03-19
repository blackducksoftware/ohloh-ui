class ProjectWidget::ThinBadge < ProjectWidget
  def short_nice_name
    I18n.t('project_widgets.thin_badge.short_nice_name')
  end

  def width
    145
  end

  def height
    32
  end

  def image
    strings = [{ text: project.name.truncate(length: 18), align: :center }]
    if project.best_analysis_id.to_i > 0
      analysis = project.best_analysis
      strings << { text: I18n.t('project_widgets.partner_badge.lines', count: analysis.code_total.to_human),
                   align: :center }
      strings << { text: I18n.t('project_widgets.partner_badge.cost', count: analysis.cocomo_value.to_human),
                   align: :center }
      strings << { text: I18n.t('project_widgets.partner_badge.head_count',
                                text: I18n.t('project_widgets.partner_badge.developer').pluralize(analysis.headcount),
                                count: analysis.headcount.to_human),
                   align: :center }
    end
    strings << {text: 'Metrics by Open Hub', align: :center}
    ThinBadge.create(strings)
  end

  def position
    10
  end
end
