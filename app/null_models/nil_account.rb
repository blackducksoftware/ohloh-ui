# frozen_string_literal: true

class NilAccount < NullObject
  attr_reader :id, :level, :activated_at

  nil_methods :admin?

  def actions
    Action.none
  end

  def access
    @access ||= Account::Access.new(self)
  end
end
