class ProjectWidget::ThinBadge < ProjectWidget
  def short_nice_name
    I18n.t('project_widgets.project_thin_badge.short_nice_name')
  end

  def width
    145
  end

  def height
    32
  end

  def image
    image_data = [{ text: project.name.truncate(18).shellescape, align: :center }]
    image_data += [lines_text, cost_text, head_count_text] if analysis.present?
    image_data += [{ text: 'Metrics by Open Hub', align: :center }]
    WidgetBadge::Thin.create(image_data)
  end

  def position
    10
  end
end
