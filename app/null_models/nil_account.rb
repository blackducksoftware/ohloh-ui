class NilAccount < NullObject
  attr_reader :id, :level, :activated_at

  def actions
    Action.none
  end

  def admin?
  end

  def id
    nil
  end
end
