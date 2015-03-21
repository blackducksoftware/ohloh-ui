class ProjectWidget < Widget
  def initialize(vars = {})
    fail ArgumentError I18n.t('project_widgets.missing') unless vars[:project_id]
    super
  end

  def project
    @project ||= Project.from_param(project_id).first
  end

  def title
    I18n.t('project_widgets.title')
  end

  def border
    0
  end

  def width
    380
  end

  class << self
    def create_widgets(project_id)
      widgets_classes = descendants.select { |widget| widget != ProjectWidget::Users }
      widgets = widgets_classes.map { |widget| widget.new(project_id: project_id) }
      widgets += ProjectWidget::Users.instantiate_styled_badges(project_id: project_id)
      widgets.select { |w| w.can_display? }.sort_by(&:position)
    end
  end
end
