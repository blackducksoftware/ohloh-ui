# frozen_string_literal: true

class Widget::ProjectWidget::Users < Widget::ProjectWidget
  POSITIONS_MAP = { gray: 13, rainbow: 17, green: 14, red: 15, blue: 16 }.freeze
  STYLES = ['gray', 'rainbow', 'green', 'red', 'blue', nil].freeze
  COLOR_MAP = { green: '#197B30', red: '#E11717', gray: '#525456', blue: '#036CB6', rainbow: nil }.freeze

  def short_nice_name
    I18n.t('project_widgets.users.short_nice_name', text: style ? style.capitalize : 'Simple')
  end

  def height
    115
  end

  def background_color
    style && COLOR_MAP[style.to_sym]
  end

  def width
    95
  end

  def title
    I18n.t('project_widgets.users.title')
  end

  def position
    style ? POSITIONS_MAP[style.to_sym] : 12
  end

  class << self
    def instantiate_styled_badges(project_id:)
      STYLES.map { |style| new(project_id: project_id, style: style) }
    end
  end
end
