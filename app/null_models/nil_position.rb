# frozen_string_literal: true

class NilPosition < NullObject
  attr_reader :title

  def active?
    false
  end
end
