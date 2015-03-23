class ProjectWidget::PartnerBadge < ProjectWidget
  def short_nice_name
    I18n.t('project_widgets.partner_badge.short_nice_name')
  end

  def width
    245
  end

  def height
    50
  end

  # TODO: Implement this when mini_magick is taken care of
  def image
    # strings = [{ text: project.name.truncate(length: 16), align: :center }]

    # unless project.best_analysis.nil?
    #   analysis = project.best_analysis
    #   strings << { text: I18n.t('project_widgets.partner_badge.lines', count: analysis.code_total.to_human),
    #                align: :center }
    #   strings << { text: I18n.t('project_widgets.partner_badge.cost', count: analysis.cocomo_value.to_human),
    #                align: :center }
    #   strings << { text: I18n.t('project_widgets.partner_badge.head_count',
    #                             text: I18n.t('project_widgets.partner_badge.developer').pluralize(analysis.headcount),
    #                             count: analysis.headcount.to_human),
    #                align: :center }
    # end

    # PartnerBadge.create(strings)
  end

  def position
    9
  end
end
