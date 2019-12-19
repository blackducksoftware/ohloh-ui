# frozen_string_literal: true

module FooterHelper
  LINKS = %w[settings edit index].freeze

  def selected?(params, link_class)
    link_class.to_s == LINKS[0] && LINKS.include?(params)
  end
end
