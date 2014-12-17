class NullAccount
  def id
    nil
  end

  def admin?
    false
  end

  def actions
    Action.none
  end
end
