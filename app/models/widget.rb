class Widget
  KEYS_TO_BE_REMOVED = %i[controller format action].freeze

  attr_reader :vars

  def initialize(vars = {})
    @vars = vars.with_indifferent_access.delete_if { |key, _| KEYS_TO_BE_REMOVED.include? key.to_sym }
  end

  def title
    I18n.t('widgets.title')
  end

  def description
    I18n.t('widgets.description')
  end

  def nice_name
    name.titleize
  end

  def short_nice_name
    nice_name.split(' ').last
  end

  def name
    self.class.name.split('::').last
  end

  def height
    @vars[:height] || 0
  end

  def width
    @vars[:width] || 0
  end

  def can_display?
    true
  end

  def method_missing(method)
    return @vars[method] if @vars.include?(method)

    super
  end

  def respond_to_missing?(method_name)
    @vars.include?(method_name)
  end
end
