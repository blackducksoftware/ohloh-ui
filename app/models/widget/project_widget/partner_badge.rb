# frozen_string_literal: true

class Widget::ProjectWidget::PartnerBadge < Widget::ProjectWidget
  def short_nice_name
    I18n.t('project_widgets.partner_badge.short_nice_name')
  end

  def width
    245
  end

  def height
    50
  end

  def image
    image_data = [{ text: project.name.truncate(16).escape_single_quote, align: :center }]
    image_data += [lines_text, cost_text, head_count_text] if analysis.present?

    WidgetBadge::Partner.create(image_data)
  end

  def position
    9
  end
end
