# frozen_string_literal: true

module LogosHelper
  def default_logos
    logos = Logo.where(id: Logo::DEFAULT_LOGOS.keys).to_a
    Logo::DEFAULT_LOGOS.map do |key, value|
      [value, logos.find { |l| l.id == key }]
    end
  end
end
