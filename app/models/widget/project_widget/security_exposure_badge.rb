class ProjectWidget::SecurityExposureBadge < ProjectWidget
  def short_nice_name
    I18n.t('project_widgets.security_exposure_badge.short_nice_name')
  end

  def width
    245
  end

  def height
    50
  end

  def image
    pvr = project.project_vulnerability_report
    image_data = [{ text: project.name.truncate(18).shellescape, align: :center }]
    image_data += [pss_text(pvr)] if pvr
    image_data += [{ text: I18n.t('project_widgets.security_exposure_badge.text'), align: :center }]
    WidgetBadge::Partner.create(image_data)
  end

  def position
    24
  end

  private

  def pss_text(pvr)
    { text: ProjectWidgetsController.helpers.pss_content(pvr), align: :center }
  end
end
