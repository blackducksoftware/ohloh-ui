# frozen_string_literal: true

class OrganizationWidget < Widget
  def initialize(vars = {})
    raise ArgumentError I18n.t('organization_widgets.missing') unless vars[:organization_id]

    super
  end

  def organization
    @organization ||= Organization.from_param(organization_id).first
  end
  alias parent organization

  def title
    I18n.t('organization_widgets.title')
  end

  def border
    0
  end

  def height
    200
  end

  def width
    328
  end

  class << self
    def create_widgets(org_id)
      descendants.map { |widget| widget.new(organization_id: org_id) }.sort_by(&:position)
    end
  end
end
