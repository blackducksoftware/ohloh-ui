class NilAccount < NullObject
  attr_reader :id, :level, :activated_at

  def actions
    Action.none
  end
end
