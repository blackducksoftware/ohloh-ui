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
    image_data = [{ text: project.name.truncate(18), align: :center }]
    if project.best_analysis.present?
      analysis = project.best_analysis
      image_data << { text: I18n.t('project_widgets.partner_badge.lines', count: analysis.code_total.to_human),
                   align: :center }
      image_data << { text: I18n.t('project_widgets.partner_badge.cost', count: analysis.cocomo_value.to_human),
                   align: :center }
      image_data << { text: I18n.t('project_widgets.partner_badge.head_count',
                                text: I18n.t('project_widgets.partner_badge.developer').pluralize(analysis.headcount),
                                count: analysis.headcount.try(:to_human)),
                   align: :center }
    end
    image_data << { text: 'Metrics by Open Hub', align: :center }
    WidgetBadge::Thin.create(image_data)
  end

  def position
    10
  end
end
