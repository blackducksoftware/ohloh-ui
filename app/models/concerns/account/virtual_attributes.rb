# frozen_string_literal: true

module Account::VirtualAttributes
  extend ActiveSupport::Concern

  included do
    attr_reader :about_raw
  end

  def about_raw=(value)
    @about_raw = value
    about_markup_id.nil? ? build_markup(raw: value) : markup.raw = value
  end
end
