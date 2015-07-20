class ProjectWidget::PartnerBadge < ProjectWidget
  def short_nice_name
    I18n.t('project_widgets.project_partner_badge.short_nice_name')
  end

  def width
    245
  end

  def height
    50
  end

  def image
    image_data = [{ text: project.name.truncate(16).shellescape, align: :center }]
    image_data += [lines_text, cost_text, head_count_text] if analysis.present?

    WidgetBadge::Partner.create(image_data)
  end

  def position
    9
  end
end
