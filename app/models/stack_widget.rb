# frozen_string_literal: true

class StackWidget < Widget
  MIN_INITIAL_ICONS_PER_ROW = 3
  MAX_INITIAL_ICONS_PER_ROW = 12
  MAX_ICONS_SHOWN = 24

  def initialize(vars = {})
    vars = vars.with_indifferent_access
    p = { icon_width: 16, icon_height: 16, projects_shown: MAX_ICONS_SHOWN }
    p.merge!(vars.symbolize_keys)
    p[:projects_shown] = [MAX_ICONS_SHOWN, p[:projects_shown].to_i].min

    raise ArgumentError, I18n.t('stack_widgets.missing') unless vars[:stack_id]

    super(p)
  end

  def name
    'normal'
  end

  def stack
    @stack ||= Stack.find(stack_id)
  end
  alias parent stack

  def stack_entries
    @stack_entries = stack.stack_entries.limit(projects_shown)
  end

  def more
    stack.stack_entries.size - projects_shown.to_i
  end

  def initial_icons_width
    dx_icons = [MAX_INITIAL_ICONS_PER_ROW, stack.project_count].min
    dx_icons = [MIN_INITIAL_ICONS_PER_ROW, dx_icons].max
    dx_icons
  end

  def width
    icon_height.to_i == 12 ? 114 : 130
  end

  def height
    @vars[:width].to_i + 27
  end

  def position
    1
  end
end
