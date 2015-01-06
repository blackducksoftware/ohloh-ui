class NullAccount
  def id
    nil
  end

  def level
    nil
  end

  def admin?
    false
  end

  def actions
    Action.none
  end
end
