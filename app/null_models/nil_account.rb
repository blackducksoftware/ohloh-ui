# frozen_string_literal: true

class NilAccount < NullObject
  attr_reader :id, :level, :activated_at

  def actions
    Action.none
  end

  def admin?; end

  def access
    @access ||= Account::Access.new(self)
  end
end
