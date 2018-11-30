class ProjectWidget < Widget
  def initialize(vars = {})
    raise ArgumentError I18n.t('project_widgets.missing') unless vars[:project_id]
    super
  end

  def project
    @project ||= Project.from_param(project_id).first
  end
  alias parent project

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
      widgets_classes = descendants.reject { |widget| widget == ProjectWidget::Users }
      widgets = widgets_classes.map { |widget| widget.new(project_id: project_id) }
      widgets += ProjectWidget::Users.instantiate_styled_badges(project_id: project_id)
      widgets.select(&:can_display?).sort_by(&:position)
    end
  end

  private

  def analysis
    project.best_analysis
  end

  def lines_text
    { text: I18n.t('project_widgets.partner_badge.lines', count: analysis.code_total.to_human), align: :center }
  end

  def cost_text
    { text: I18n.t('project_widgets.partner_badge.cost', count: analysis.cocomo_value.to_human),
      align: :center }
  end

  def head_count_text
    head_count = analysis.headcount.try(:to_human)
    developers = I18n.t('project_widgets.partner_badge.developer').pluralize(analysis.headcount)
    count_text = I18n.t('project_widgets.partner_badge.head_count', text: developers, count: head_count)
    { text: count_text, align: :center }
  end
end
